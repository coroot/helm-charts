#!/usr/bin/env bash
# Regression tests for the optional spec.httpRoute (Gateway API) feature.
#
# Covers: default CR without httpRoute, CE/EE example values (filter types/
# namespace) round-tripping into the Coroot CR, operator RBAC (incl.
# denyGlobalSecrets), and the new httpRoute schema in modern+legacy CRDs.
#
# Usage: tests/httproute.sh   (runs from any cwd; needs helm + yq)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHARTS="$ROOT/charts"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
ok() { echo "ok   - $1"; pass=$((pass + 1)); }
fail() { echo "FAIL - $1" >&2; exit 1; }

# --- helpers -------------------------------------------------------------
# render <chart-dir> [extra helm args...] -> stdout
render() {
  local chart="$1"; shift
  helm template "test-release" "$CHARTS/$chart" "$@"
}

# cr <chart-dir> [extra helm args...] -> the rendered Coroot CR document
cr() {
  render "$@" | yq e 'select(.kind == "Coroot")' -
}

# uncomment the "#httpRoute:" example block from a values file
example_values() {
  awk '/^#httpRoute:$/{f=1} f && /^#/{sub(/^#/, ""); print; next} f {exit}' "$1"
}

# --- 1. default values: no httpRoute in the rendered CR -------------------
for chart in coroot-ce coroot-ee; do
  [ "$(cr "$chart" | yq e '.spec.httpRoute // "absent"')" = "absent" ] \
    || fail "$chart: default render must not contain spec.httpRoute"
  ok "$chart: default CR has no spec.httpRoute"
done

# --- 2. CE/EE example values preserved, incl. filters and namespace -------
for chart in coroot-ce coroot-ee; do
  example_values "$CHARTS/$chart/values.yaml" > "$TMP/$chart.hr.yaml"
  [ -s "$TMP/$chart.hr.yaml" ] || fail "$chart: httpRoute example block not found in values.yaml"
  spec="$(cr "$chart" -f "$TMP/$chart.hr.yaml")"
  q() { echo "$spec" | yq e "$1"; }
  [ "$(q '.spec.httpRoute.parentRefs[0].name')" = "coroot-gateway" ] \
    || fail "$chart: parentRefs name not preserved"
  [ "$(q '.spec.httpRoute.parentRefs[0].namespace')" = "gateway-infra" ] \
    || fail "$chart: parentRefs namespace not preserved"
  [ "$(q '.spec.httpRoute.parentRefs[0].sectionName')" = "http" ] \
    || fail "$chart: parentRefs sectionName not preserved"
  [ "$(q '.spec.httpRoute.hostnames[0]')" = "coroot.example.com" ] \
    || fail "$chart: hostnames not preserved"
  [ "$(q '.spec.httpRoute.path')" = "/" ] || fail "$chart: path not preserved"
  [ "$(q '.spec.httpRoute.filters[0].requestHeaderModifier.add[0].name')" = "X-Coroot" ] \
    || fail "$chart: standard filter not preserved"
  [ "$(q '.spec.httpRoute.filters[0].requestHeaderModifier.add[0].value')" = "helm" ] \
    || fail "$chart: standard filter value not preserved"
  [ "$(q '.spec.httpRoute.filters[0].type')" = "RequestHeaderModifier" ] \
    || fail "$chart: standard filter type must be RequestHeaderModifier"
  [ "$(q '.spec.httpRoute.filters[1].extensionRef | .group + "/" + .kind + "/" + .name')" = "traefik.io/Middleware/strip-prefix" ] \
    || fail "$chart: extensionRef filter not preserved"
  [ "$(q '.spec.httpRoute.filters[1].type')" = "ExtensionRef" ] \
    || fail "$chart: extension filter type must be ExtensionRef"
  ok "$chart: example httpRoute values (parentRefs/hostnames/path/typed filters) reach the CR spec"
done

# --- 3. operator RBAC: httproutes CRUD, denyGlobalSecrets preserved -------
op_default="$(render operator)"
op_denied="$(render operator --set rbac.denyGlobalSecrets=true)"

httproute_verbs() {
  yq e 'select(.kind == "ClusterRole") | .rules[] | select(.apiGroups[]? == "gateway.networking.k8s.io") | select(.resources[]? == "httproutes") | .verbs | sort | join(",")' <<<"$1"
}
[ "$(httproute_verbs "$op_default")" = "create,delete,get,list,patch,update,watch" ] \
  || fail "operator ClusterRole missing full httproutes CRUD (default)"
[ "$(httproute_verbs "$op_denied")" = "create,delete,get,list,patch,update,watch" ] \
  || fail "operator ClusterRole missing full httproutes CRUD (denyGlobalSecrets=true)"
ok "operator ClusterRole has gateway.networking.k8s.io httproutes CRUD"

core_secrets() {
  yq e 'select(.kind == "ClusterRole") | .rules[] | select(.resources[]? == "secrets") | .verbs | length' <<<"$1" | grep -c . || true
}
[ "$(core_secrets "$op_default")" = "1" ] \
  || fail "default ClusterRole must still contain secrets (denyGlobalSecrets=false)"
[ "$(core_secrets "$op_denied")" = "0" ] \
  || fail "denyGlobalSecrets=true must drop secrets from the ClusterRole"
role_secrets="$(yq e 'select(.kind == "Role") | .rules[] | select(.resources[]? == "secrets") | .verbs | sort | join(",")' <<<"$op_denied")"
[ "$role_secrets" = "create,get,list,update,watch" ] \
  || fail "denyGlobalSecrets=true must keep the namespaced secrets Role with create/get/list/update/watch"
[ "$(yq e 'select(.kind == "Role") | .metadata.name' <<<"$op_default" | grep -c . || true)" = "0" ] \
  || fail "default render must not contain the namespaced secrets Role"
ok "denyGlobalSecrets conditional unchanged (global vs namespaced secrets)"

# --- 4. new httpRoute schema: modern + legacy ------------------------------
modern="$CHARTS/operator/files/crd.yaml"
legacy="$CHARTS/operator/files/crd-legacy.yaml"
hr_props() { yq e ".spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.httpRoute.properties | keys | join(\",\")" "$1"; }
want="annotations,filters,hostnames,parentRefs,path"
[ "$(hr_props "$modern")" = "$want" ] || fail "modern CRD: httpRoute properties wrong: $(hr_props "$modern")"
[ "$(hr_props "$legacy")" = "$want" ] || fail "legacy CRD: httpRoute properties wrong: $(hr_props "$legacy")"
[ "$(yq e '.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.httpRoute.required | join(",")' "$modern")" = "parentRefs" ] \
  || fail "modern CRD: httpRoute.required must be [parentRefs]"
[ "$(yq e '.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.httpRoute.nullable' "$legacy")" = "true" ] \
  || fail "legacy CRD: httpRoute must be nullable"
# filters: standard + extensionRef with full group/kind/name
ext_req="$(yq e '.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.httpRoute.properties.filters.items.properties.extensionRef.required | join(",")' "$modern")"
[ "$ext_req" = "group,kind,name" ] || fail "modern CRD: extensionRef.required wrong: $ext_req"
[ "$(yq e '.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.httpRoute.properties.filters.items.properties | keys | contains(["requestHeaderModifier", "extensionRef"])' "$legacy")" = "true" ] \
  || fail "legacy CRD: filter items must allow standard and extensionRef filters"
[ "$(yq e '.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.httpRoute.properties.filters.items.required | join(",")' "$modern")" = "type" ] \
  || fail "modern CRD: filter items must require type"
# limits: parentRefs 1..32
[ "$(yq e '.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.httpRoute.properties.parentRefs | [.minItems, .maxItems] | join(",")' "$modern")" = "1,32" ] \
  || fail "modern CRD: parentRefs limits must be minItems 1 / maxItems 32"
for f in "$modern" "$legacy"; do
  for field in filters hostnames; do
    [ "$(yq e ".spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.httpRoute.properties.$field.maxItems" "$f")" = "16" ] \
      || fail "$f: $field must have maxItems=16"
  done
done
ok "modern+legacy CRDs carry the httpRoute subtree (schema + limits)"

# --- 5. operator chart serves the right CRD per kube version ---------------
modern_rendered="$(render operator --kube-version 1.28.0)"
legacy_rendered="$(render operator --kube-version 1.17.17)"
[ "$(yq e 'select(.kind == "CustomResourceDefinition") | .spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.httpRoute.nullable // "absent"' <<<"$modern_rendered")" = "absent" ] \
  || fail "modern render: legacy CRD (nullable httpRoute) must not be selected on >=1.18"
[ "$(yq e 'select(.kind == "CustomResourceDefinition") | .spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.httpRoute.nullable' <<<"$legacy_rendered")" = "true" ] \
  || fail "legacy render: nullable httpRoute CRD must be selected on 1.17"
ok "operator chart selects modern CRD (>=1.18) and legacy CRD (1.17)"

echo "PASS: $pass checks"
