{{- define "monitors-manager.fullname" -}}
{{- printf "%s-monitors-manager" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "monitors-manager.secretName" -}}
{{- default (include "monitors-manager.fullname" .) (index .Values "monitors-manager" "admin" "existingSecret") -}}
{{- end -}}

{{- define "monitors-manager.secret.userKey" -}}
{{ default "admin-user" (index .Values "monitors-manager" "admin" "userKey") }}
{{- end -}}

{{- define "monitors-manager.secret.passwordKey" -}}
{{ default "admin-password" (index .Values "monitors-manager" "admin" "passwordKey") }}
{{- end -}}

{{- define "monitors-manager.httpEndpoint" -}}
{{- printf "http://%s:%d" (include "monitors-manager.fullname" .) (index .Values "monitors-manager" "service" "port" | int ) -}}
{{- end -}}
