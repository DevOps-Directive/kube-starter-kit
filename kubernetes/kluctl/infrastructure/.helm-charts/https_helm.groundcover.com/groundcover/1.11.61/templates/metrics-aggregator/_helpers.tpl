{{- define "metrics-aggregator.fullname" -}}
    {{- printf "%s-metrics-aggregator" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "metrics-aggregator.monitoring.port" -}}
    {{- default 9102 (.Values.metricsAggregator.monitoring).port -}}
{{- end -}}

{{/*
Create the write URL for metrics-aggregator
This helper chooses between vmauth (when victoria-metrics-distributed is enabled) 
or vmsingle (when victoria-metrics-distributed is disabled)
*/}}
{{- define "metrics-aggregator.write.url" -}}
{{- if index .Values.global.backend "victoria-metrics-distributed" "enabled" -}}
  {{- include "victoria-metrics-distributed.vmauthWriteBalancerUrl" . -}}
{{- else -}}
  {{- (printf "%s://%s/%s" (include "victoria-metrics.write.http.scheme" .) (include "victoria-metrics.write.http.hostport" .) (include "victoria-metrics.write.http.path" .)) | trimSuffix "/" -}}
{{- end -}}
{{- end -}}