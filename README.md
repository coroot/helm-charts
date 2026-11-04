# Coroot Helm Charts

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Official Helm charts for deploying [Coroot](https://coroot.com) - an open-source observability platform that helps you understand and troubleshoot your systems faster.

Documentation: follow the official installation guide here: [docs.coroot.com/installation/kubernetes](https://docs.coroot.com/installation/kubernetes)

## Coroot via HTTPRoute (Gateway API)

`coroot-ce` and `coroot-ee` accept an optional `httpRoute` value instead of `ingress`. The operator manages an `HTTPRoute` named after the release in the same namespace as the `Coroot` resource, pointing at an **existing Gateway** (TLS terminates at the Gateway; the certificate is external to the chart):

```yaml
httpRoute:
  parentRefs:
    - name: my-gateway          # existing Gateway
      namespace: gateway-infra  # the Gateway's namespace; omit it when the Gateway is in this namespace
      sectionName: http         # selects the listener by name, independently of namespace
  hostnames:
    - coroot.example.com
  path: /                     # prefix, default "/"
  filters:                    # optional Gateway API HTTPRouteFilter list; each item needs its `type`
    - type: RequestHeaderModifier
      requestHeaderModifier:
        add:
          - name: X-Coroot
            value: helm
    - type: ExtensionRef      # e.g. an existing Traefik Middleware in the same namespace
      extensionRef:
        group: traefik.io
        kind: Middleware
        name: strip-prefix
```

Prerequisites and notes:

- Requires an operator release that implements `spec.httpRoute`. `httpRoute` is mutually exclusive with `ingress` and not supported with `httpDisabled: true`.
- Gateway API CRDs and a Gateway API controller (e.g. Traefik) are user-managed. If you use `httpRoute`, install the Gateway CRDs before the operator starts (or restart it afterwards). With Traefik, enable its Gateway provider (`providers.kubernetesGateway.enabled: true`) and, for `extensionRef` filters to a `Middleware`, the `kubernetesCRD` provider (`providers.kubernetesCRD.enabled: true`).
- Cross-namespace routing is controlled by the Gateway listener's `spec.listeners[].allowedRoutes.namespaces.from`: `Same` by default, `All`, or `Selector` together with `allowedRoutes.namespaces.selector`; no `ReferenceGrant` is needed merely for the route -> Gateway direction.
- Filters reference **existing** resources; an `extensionRef` to a Traefik `Middleware` requires that middleware in the same namespace as the route.

## License

[Apache 2.0 License](https://github.com/coroot/helm-charts/blob/main/LICENSE).
