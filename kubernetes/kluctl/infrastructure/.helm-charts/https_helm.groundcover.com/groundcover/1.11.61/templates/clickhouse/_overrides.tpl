{{/*
Get the Clickhouse password secret name
*/}}
{{- define "clickhouse.secretName" -}}
{{- default (include "clickhouse.fullname" .) .Values.global.clickhouse.auth.existingSecret -}}
{{- end -}}

{{/*
Get the ClickHouse password key inside the secret
*/}}
{{- define "clickhouse.secretKey" -}}
{{ .Values.global.clickhouse.auth.existingSecretKey }}
{{- end -}}


{{/*
Create the name of the service account to use
*/}}
{{- define "clickhouse.serviceAccountName" -}}
{{- if .Values.global.clickhouse.serviceAccount.create -}}
    {{ default (include "clickhouse.fullname" .) .Values.global.clickhouse.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.global.clickhouse.serviceAccount.name }}
{{- end -}}
{{- end -}}
