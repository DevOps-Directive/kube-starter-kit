{{/*
Temporal helpers
*/}}

{{/*
Node selector for temporal pods
*/}}
{{- define "temporal.nodeSelector" -}}
{{- if .Values.global.temporal.nodeSelector -}}
{{- toYaml .Values.global.temporal.nodeSelector | nindent 0 -}}
{{- else if .Values.temporal.nodeSelector -}}
{{- toYaml .Values.temporal.nodeSelector | nindent 0 -}}
{{- end -}}
{{- end -}}

{{/*
Tolerations for temporal pods
*/}}
{{- define "temporal.tolerations" -}}
{{- if .Values.global.temporal.tolerations -}}
{{- toYaml .Values.global.temporal.tolerations | nindent 0 -}}
{{- else if .Values.temporal.tolerations -}}
{{- toYaml .Values.temporal.tolerations | nindent 0 -}}
{{- end -}}
{{- end -}}