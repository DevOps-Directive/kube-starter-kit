{{- define "metrics-ingester.fullname" -}}
{{- printf "%s-metrics-ingester" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "metrics-ingester.http.scheme" -}}
{{- ternary "https" "http" .Values.global.metrics.tls.enabled -}}
{{- end -}}

{{- define "metrics-ingester.cluster.http.write.url" -}}
{{- printf "%s/api/v1/write" (include "metrics-ingester.cluster.http.base.url" .) -}}
{{- end -}}

{{- define "metrics-ingester.cluster.http.base.url" -}}
{{- printf "%s://%s:%d" (include "metrics-ingester.http.scheme" .) (include "metrics-ingester.fullname" .) (index .Values.global "metrics-ingester" "service" "servicePort" | int ) -}}
{{- end -}}

{{- define "metrics-ingester.base.http.url" -}}
{{- if .Values.global.metrics.overrideUrl -}}
    {{- .Values.global.metrics.overrideUrl -}}
{{- else if .Values.global.backend.enabled -}}
    {{- include "metrics-ingester.cluster.http.base.url" . -}}
{{- else if .Values.global.ingress.site -}}
    {{- include "incloud.metrics.http.url" . -}}
{{- else  -}}
    {{- fail "A valid global.ingress.site or .Values.global.metrics.overrideUrl is required!" -}}
{{- end -}}
{{- end -}}

{{- define "metrics-ingester.datadog.http.v1.url" -}}
{{- printf "%s/datadog/api/v1/series" (include "metrics-ingester.base.http.url" .) -}}
{{- end -}}

{{- define "metrics-ingester.datadog.http.v2.url" -}}
{{- printf "%s/datadog/api/v2/series" (include "metrics-ingester.base.http.url" .) -}}
{{- end -}}

{{- define "metrics-ingester.datadog.http.beta.sketches.url" -}}
{{- printf "%s/datadog/api/beta/sketches" (include "metrics-ingester.base.http.url" .) -}}
{{- end -}}

{{- define "metrics-ingester.write.http.url" -}}
{{- printf "%s/api/v1/write" (include "metrics-ingester.base.http.url" .) -}}
{{- end -}}

{{- define "metrics-ingester.health.http.url" -}}
{{- printf "%s/health" (include "metrics-ingester.base.http.url" .) -}}
{{- end -}}

{{- define "metrics-ingester.promethues-exposition.http.url" -}}
{{- printf "%s/api/v1/import/prometheus" (include "metrics-ingester.base.http.url" .) -}}
{{- end -}}

{{/*
binary config facade helper
*/}}
{{- define "ingester.vmCLIConfigHelper" -}}
  {{- $ctx := .Context -}}
  {{- $field := .Field -}}
  {{- $mode := (ternary "backend" "sensor" $ctx.Values.global.backend.enabled) -}}
  {{- $destinations := (index .Destinations $mode) -}}

  {{- $result := tpl (index $destinations $field) $ctx -}}

  {{/* guard vm order & quantity dependent param array misconfiguration */}}
  {{- $required_items_count := (index $destinations "url") | split "," | len -}}
  {{- $actual_items_count := $result | split "," | len -}}
  {{- if ne $required_items_count $actual_items_count -}}
    {{- printf ".global.metrics.write.destinations.%s.url has %d params, .global.metrics.write.destinations.%s.%s must have equivalent number of params (has %d)" $mode $required_items_count $mode $field $actual_items_count | fail -}}
  {{- end -}}

  {{- $result -}}
{{- end -}}

{{- define "ingester.buildRemoteWriteURLTargets" -}}
{{- include "ingester.vmCLIConfigHelper" (dict "Destinations" .Values.global.metrics.write.destinations "Field" "url" "Context" .) }}
{{- end -}}

{{- define "ingester.buildRemoteWriteRateLimit" -}}
{{- include "ingester.vmCLIConfigHelper" (dict "Destinations" .Values.global.metrics.write.destinations "Field" "rateLimit" "Context" .) }}
{{- end -}}

{{- define "ingester.buildRemoteWriteDisableOnDiskQueue" -}}
{{- include "ingester.vmCLIConfigHelper" (dict "Destinations" .Values.global.metrics.write.destinations "Field" "disableOnDiskQueue" "Context" .) }}
{{- end -}}

{{- define "ingester.buildRemoteWriteForcePromProto" -}}
{{- include "ingester.vmCLIConfigHelper" (dict "Destinations" .Values.global.metrics.write.destinations "Field" "forcePromProto" "Context" .) }}
{{- end -}}

{{- define "ingester.buildRemoteWriteMaxDiskUsagePerURL" -}}
{{- include "ingester.vmCLIConfigHelper" (dict "Destinations" .Values.global.metrics.write.destinations "Field" "maxDiskUsagePerURL" "Context" .) }}
{{- end -}}

{{- define "ingester.buildRemoteWriteForceVMProto" -}}
{{- include "ingester.vmCLIConfigHelper" (dict "Destinations" .Values.global.metrics.write.destinations "Field" "forceVMProto" "Context" .) }}
{{- end -}}
