{{- define "ingestor.fullname" -}}
    {{- printf "%s-ingestor" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ingestor.monitoring.port" -}}
    {{- default 9102 (.Values.ingestor.monitoring).port -}}
{{- end -}}