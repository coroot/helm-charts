{{- define "coroot-agent.params" -}}
- coroot-node-agent
{{- if .Values.agent.port }}
- --listen={{ .Values.agent.port }}
{{- end }}
{{- if .Values.agent.cgroupfsRoot }}
- --cgroupfs-root={{ .Values.agent.cgroupfsRoot }}
{{- end }}
{{- if .Values.agent.disableLogParsing }}
- --disable-log-parsing
{{- end }}
{{- if .Values.agent.disableL7Tracing }}
- --disable-log-parsing"
{{- end }}
{{- if .Values.agent.trackPublicNetwork }}
- --track-public-network={{ .Values.agent.trackPublicNetwork }}
{{- end }}
{{- if .Values.agent.ephemeralPortRange }}
- --track-public-network={{ .Values.agent.ephemeralPortRange }}
{{- end }}
{{- if .Values.agent.provider }}
- --provider={{ .Values.agent.provider  }}
{{- end }}
{{- if .Values.agent.region }}
- --region={{ .Values.agent.region  }}
{{- end }}
{{- if .Values.agent.az }}
- --availability-zone={{ .Values.agent.az  }}
{{- end }}
{{- if .Values.agent.instanceType }}
- --availability-zone={{ .Values.agent.instanceType  }}
{{- end }}
{{- if .Values.agent.instanceLifeCycle }}
- --instance-life-cycle={{ .Values.instanceLifeCycle }}
{{- end }}
{{- end -}}
