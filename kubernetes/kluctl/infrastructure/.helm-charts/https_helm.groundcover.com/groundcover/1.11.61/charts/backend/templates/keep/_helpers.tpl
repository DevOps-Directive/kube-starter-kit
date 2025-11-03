{{- define "keep.postgres.password" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace "keep-postgres" | default dict) -}}
{{- if $secret -}}
    {{- index $secret "data" "password" | b64dec -}}
{{- else -}}
    {{- randAlphaNum 16 -}}
{{- end -}}
{{- end -}}

{{- define "keep.webhook.apikey" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace "keep-credentials" | default dict) -}}
{{- if $secret -}}
    {{- index $secret "data" "webhook-key" | b64dec -}}
{{- else -}}
    {{- randAlphaNum 16 -}}
{{- end -}}
{{- end -}}

{{- define "keep.admin.apikey" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace "keep-credentials" | default dict) -}}
{{- if $secret -}}
    {{- index $secret "data" "admin-api-key" | b64dec -}}
{{- else if .Values.global.workflows.adminApiKey -}}
    {{- .Values.global.workflows.adminApiKey -}}
{{- else -}}
    {{- randAlphaNum 16 -}}
{{- end -}}
{{- end -}}

{{- define "keep.backend.fullname" -}}
{{- printf "%s-keep-backend" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "keep.admin.password" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace "keep-credentials" | default dict) -}}
{{- if $secret -}}
    {{- index $secret "data" "password" | b64dec -}}
{{- else -}}
    {{- randAlphaNum 16 -}}
{{- end -}}
{{- end -}}

{{- define "keep.base.url" -}}
{{ printf "http://%s:8080" (include "keep.backend.fullname" .)  -}}
{{- end -}}

{{- define "keep.event.alert.url" -}}
{{ printf "%s/alerts/event/grafana" (include "keep.base.url" .) }}
{{- end -}}