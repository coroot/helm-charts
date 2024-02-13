{{/*
Expand the name of the chart.
*/}}
{{- define "coroot.name" -}}
{{- default .Chart.Name .Values.corootCE.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "coroot.namespace" -}}
{{- .Release.Namespace -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "coroot.fullname" -}}
{{- if .Values.corootCE.fullnameOverride }}
{{- .Values.corootCE.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.corootCE.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "coroot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "coroot.labels" -}}
helm.sh/chart: {{ include "coroot.chart" . }}
{{ include "coroot.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "coroot.selectorLabels" -}}
app.kubernetes.io/name: {{ include "coroot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "coroot.serviceAccountName" -}}
{{- if .Values.corootCE.serviceAccount.create }}
{{- default (include "coroot.fullname" .) .Values.corootCE.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.corootCE.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Coroot Connect
*/}}
{{- define "corootConnect.name" -}}
{{- printf "%s-connect" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "corootConnect.selectorLabels" -}}
app.kubernetes.io/name: {{ include "corootConnect.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- define "corootConnect.labels" -}}
helm.sh/chart: {{ include "coroot.chart" . }}
{{ include "corootConnect.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.corootConnect.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Coroot Cluster Agent
*/}}
{{- define "corootClusterAgent.name" -}}
{{- if .Values.corootClusterAgent.fullnameOverride -}}
{{- .Values.corootClusterAgent.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-cluster-agent" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- define "corootClusterAgent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "corootClusterAgent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- define "corootClusterAgent.labels" -}}
helm.sh/chart: {{ include "coroot.chart" . }}
{{ include "corootClusterAgent.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.corootClusterAgent.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Create a fully qualified Prometheus server name
in a similar way as prometheus/templates/_helpers.tpl creates "prometheus.server.fullname".
*/}}
{{- define "coroot.prometheus.server.fullname" -}}
{{- if .Values.prometheus.server.fullnameOverride -}}
{{- .Values.prometheus.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-prometheus-%s" .Release.Name .Values.prometheus.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified Clickhouse name.
*/}}
{{- define "coroot.clickhouse.fullname" -}}
{{- if .Values.clickhouse.fullnameOverride }}
{{- .Values.clickhouse.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-clickhouse" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
