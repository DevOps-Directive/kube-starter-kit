{{- define "fleet-manager.fullname" -}}
    {{- printf "%s-fleet-manager" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}