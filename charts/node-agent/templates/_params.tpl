{{- define "coroot-agent.params" -}}
- coroot-node-agent
{{- if .Values.coroot-agent.port }}
- --listen={{ .Values.coroot-agent.port }}
{{- end }}
{{- if .Values.coroot-agent.cgroupfsRoot }}
- --cgroupfs-root={{ .Values.coroot-agent.cgroupfsRoot }}
{{- end }}
{{- if .Values.coroot-agent.disableLogParsing }}
- --disable-log-parsing
{{- end }}
{{- if .Values.coroot-agent.disableL7Tracing }}
- --disable-log-parsing"
{{- end }}
{{- if .Values.coroot-agent.trackPublicNetwork }}
- --track-public-network={{ .Values.coroot-agent.trackPublicNetwork }}
{{- end }}
{{- if .Values.coroot-agent.ephemeralPortRange }}
- --track-public-network={{ .Values.coroot-agent.ephemeralPortRange }}
{{- end }}
{{- if .Values.coroot-agent.provider }}
- --provider={{ .Values.coroot-agent.provider  }}
{{- end }}
{{- if .Values.coroot-agent.region }}
- --region={{ .Values.coroot-agent.region  }}
{{- end }}
{{- if .Values.coroot-agent.az }}
- --availability-zone={{ .Values.coroot-agent.az  }}
{{- end }}
{{- if .Values.coroot-agent.instanceType }}
- --availability-zone={{ .Values.coroot-agent.instanceType  }}
{{- end }}
{{- if .Values.coroot-agent.instanceLifeCycle }}
- --instance-life-cycle={{ .Values.coroot-agent.instanceLifeCycle }}
{{- end }}
{{- end -}}
