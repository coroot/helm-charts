{{- define "corootAgent.params" -}}
- coroot-node-agent
{{- if .Values.corootAgent.port }}
- --listen={{ .Values.corootAgent.port }}
{{- end }}
{{- if .Values.corootAgent.cgroupfsRoot }}
- --cgroupfs-root={{ .Values.corootAgent.cgroupfsRoot }}
{{- end }}
{{- if .Values.corootAgent.disableLogParsing }}
- --disable-log-parsing
{{- end }}
{{- if .Values.corootAgent.disableL7Tracing }}
- --disable-log-parsing"
{{- end }}
{{- if .Values.corootAgent.trackPublicNetwork }}
- --track-public-network={{ .Values.corootAgent.trackPublicNetwork }}
{{- end }}
{{- if .Values.corootAgent.ephemeralPortRange }}
- --track-public-network={{ .Values.corootAgent.ephemeralPortRange }}
{{- end }}
{{- if .Values.corootAgent.provider }}
- --provider={{ .Values.corootAgent.provider  }}
{{- end }}
{{- if .Values.corootAgent.region }}
- --region={{ .Values.corootAgent.region  }}
{{- end }}
{{- if .Values.corootAgent.az }}
- --availability-zone={{ .Values.corootAgent.az  }}
{{- end }}
{{- if .Values.corootAgent.instanceType }}
- --availability-zone={{ .Values.corootAgent.instanceType  }}
{{- end }}
{{- if .Values.corootAgent.instanceLifeCycle }}
- --instance-life-cycle={{ .Values.corootAgent.instanceLifeCycle }}
{{- end }}
{{- end -}}
