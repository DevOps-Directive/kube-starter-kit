{{- define "victoria-metrics.server.fullname" -}}
{{- printf "%s-victoria-metrics" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "victoria-metrics.common.metaLabels" -}}
helm.sh/chart: {{ include "victoria-metrics.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "groundcover.labels" . -}}
{{- end -}}
