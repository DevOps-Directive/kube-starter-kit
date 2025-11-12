{{- define "postgresql.primary.fullname" -}}
{{- printf "%s-postgresql" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the password secret.
*/}}
{{- define "postgresql.secretName" -}}
{{- if .Values.global.postgresql.auth.existingSecret -}}
    {{- printf "%s" (tpl .Values.global.postgresql.auth.existingSecret $) -}}
{{- else if not .Values.global.postgresql.enabled -}}
    {{- fail "A valid .Values.global.postgresql.auth.existingSecret is required!" -}}
{{- else if and .Values.auth .Values.auth.existingSecret -}}
    {{- printf "%s" (tpl .Values.auth.existingSecret $) -}}
{{- else -}}
    {{- printf "%s" (include "postgresql.primary.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get the admin-password key.
*/}}
{{- define "postgresql.adminPasswordKey" -}}
{{- if .Values.global.postgresql.auth.secretKeys.adminPasswordKey -}}
    {{- printf "%s" (tpl .Values.global.postgresql.auth.secretKeys.adminPasswordKey $) -}}
{{- else if not .Values.global.postgresql.enabled -}}
    {{- fail "A valid .Values.global.postgresql.auth.secretKeys.adminPasswordKey is required!" -}}
{{- else if and .Values.auth .Values.auth.secretKeys.adminPasswordKey -}}
    {{- printf "%s" (tpl .Values.auth.secretKeys.adminPasswordKey $) -}}
{{- else -}}
    {{- "postgres-password" -}}
{{- end -}}
{{- end -}}

{{- define "postgresql.image" -}}
{{- printf "%s/%s:%s" .Values.global.postgresql.image.registry .Values.global.postgresql.image.repository .Values.global.postgresql.image.tag -}}
{{- end -}}
