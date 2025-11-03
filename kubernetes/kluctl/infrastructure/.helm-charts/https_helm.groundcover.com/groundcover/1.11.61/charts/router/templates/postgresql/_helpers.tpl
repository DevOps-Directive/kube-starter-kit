{{- define "postgresql.base.url" -}}
{{- if .Values.global.postgresql.overrideUrl -}}
    {{- .Values.global.postgresql.overrideUrl -}}
{{- else if not .Values.global.postgresql.enabled -}}
    {{- fail "A valid .Values.global.postgresql.overrideUrl is required!" -}}
{{- else -}}
    {{- printf "%s:5432" (include "postgresql.primary.fullname" .) -}}
{{- end -}}
{{- end -}}
