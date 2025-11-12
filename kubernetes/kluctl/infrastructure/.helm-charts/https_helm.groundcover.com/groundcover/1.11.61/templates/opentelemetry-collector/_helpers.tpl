{{- define "logs.retention" -}}
{{- if .Values.global.logs.retentionDays -}}
{{- printf "%dd" (.Values.global.logs.retentionDays | int)}}
{{- else -}}
{{ .Values.global.logs.retention }}
{{- end -}}
{{- end -}}

{{- define "logs.custom_retention_overrides" -}}
{{- with .Values.global.logs.custom_retention_overrides }}
{{ toYaml . | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "traces.retention" -}}
{{ .Values.global.traces.retention }}
{{- end -}}

{{- define "traces.custom_retention_overrides" -}}
{{- with .Values.global.traces.custom_retention_overrides }}
{{ toYaml . | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "events.retention" -}}
{{ .Values.global.events.retention }}
{{- end -}}

{{- define "events.custom_retention_overrides" -}}
{{- with .Values.global.events.custom_retention_overrides }}
{{ toYaml . | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "measurements.retention" -}}
{{ .Values.global.measurements.retention }}
{{- end -}}

{{- define "measurements.custom_retention_overrides" -}}
{{- with .Values.global.measurements.custom_retention_overrides }}
{{ toYaml . | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "entities.retention" -}}
{{ .Values.global.entities.retention }}
{{- end -}}

{{- define "entities.custom_retention_overrides" -}}
{{- with .Values.global.entities.custom_retention_overrides }}
{{ toYaml . | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "monitors.evaluation.retention" -}}
{{ .Values.global.monitors.evaluation.retention }}
{{- end -}}

{{- define "monitors.evaluation.custom_retention_overrides" -}}
{{- with .Values.global.monitors.evaluation.custom_retention_overrides }}
{{ toYaml . | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "monitors.instance.retention" -}}
{{ .Values.global.monitors.instance.retention }}
{{- end -}}

{{- define "monitors.instance.custom_retention_overrides" -}}
{{- with .Values.global.monitors.instance.custom_retention_overrides }}
{{ toYaml . | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "sources.retention" -}}
{{ .Values.global.sources.retention }}
{{- end -}}

{{- define "sources.custom_retention_overrides" -}}
{{- with .Values.global.sources.custom_retention_overrides }}
{{ toYaml . | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "metrics_metadata.retention" -}}
{{ .Values.global.metricsMetadata.retention }}
{{- end -}}

{{- define "metrics_metadata.custom_retention_overrides" -}}
{{- with .Values.global.metricsMetadata.custom_retention_overrides }}
{{ toYaml . | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "opentelemetry-collector.otlp.scheme" -}}
http
{{- end -}}

{{- define "opentelemetry-collector.loki.http.url" -}}
{{- $baseUrl := "" -}}
{{- if .Values.global.logs.overrideUrl -}}
    {{- $baseUrl = .Values.global.logs.overrideUrl -}}
{{- else if .Values.global.ingress.site -}}
    {{- $baseUrl = (include "incloud.otel.http.url" .) -}}
{{- else if not .Values.global.backend.enabled -}}
    {{- fail "A valid global.ingress.site or global.logs.overrideUrl is required!" -}}
{{- else -}}
    {{- $baseUrl = (printf "%s://%s:%d" (include "opentelemetry-collector.otlp.scheme" .) (include "opentelemetry-collector.fullname" .) (index .Values.global "opentelemetry-collector" "ports" "loki-http" "servicePort" | int )) -}}
{{- end -}}
{{- printf "%s/loki/api/v1/push" $baseUrl -}}
{{- end -}}

{{- define "opentelemetry-collector.otlp.tls.enabled" -}}
{{- eq (get (urlParse (include "opentelemetry-collector.otlp.http.url" .)) "scheme") "https" -}}
{{- end -}}

{{- define "opentelemetry-collector.otlp.http.url" -}}
{{- if .Values.global.otlp.overrideHttpURL -}}
    {{- print .Values.global.otlp.overrideHttpURL -}}
{{- else if .Values.global.ingress.site -}}
    {{- include "incloud.otel.http.url" . -}}
{{- else if not .Values.global.backend.enabled -}}
    {{- fail "A valid global.ingress.site or global.otlp.overrideHttpURL is required!" -}}
{{- else -}}
    {{- printf "%s://%s:%d" (include "opentelemetry-collector.otlp.scheme" .) (include "opentelemetry-collector.fullname" .) (index .Values.global "opentelemetry-collector" "ports" "otlp-http" "servicePort" | int ) -}}
{{- end -}}
{{- end -}}

{{- define "opentelemetry-collector.otlptraces.http.url" -}}
{{- printf "%s/v1/traces" (include "opentelemetry-collector.otlp.http.url" .) -}}
{{- end -}}

{{- define "opentelemetry-collector.otlplogs.http.url" -}}
{{- printf "%s/v1/logs" (include "opentelemetry-collector.otlp.http.url" .) -}}
{{- end -}}

{{- define "opentelemetry-collector.otlpmetrics.http.url" -}}
{{- printf "%s/v1/metrics" (include "opentelemetry-collector.otlp.http.url" .) -}}
{{- end -}}

{{- define "opentelemetry-collector.awsfirehose.http.url" -}}
{{- printf "%s/firehose/logs" (include "opentelemetry-collector.otlp.http.url" .) -}}
{{- end -}}

{{- define "opentelemetry-collector.httpreceiver.http.url" -}}
{{- printf "http://%s:%d/json/logs" (include "opentelemetry-collector.fullname" .) (index .Values.global "opentelemetry-collector" "ports" "http-json" "servicePort" | int ) -}}
{{- end -}}

{{- define "opentelemetry-collector.rumreceiver.http.url" -}}
{{- printf "http://%s:%d/json/rum" (include "opentelemetry-collector.fullname" .) (index .Values.global "opentelemetry-collector" "ports" "rum" "servicePort" | int ) -}}
{{- end -}}

{{- define "opentelemetry-collector.zipkin.http.url" -}}
{{- printf "%s/api/v2/spans" (include "opentelemetry-collector.otlp.http.url" .) -}}
{{- end -}}

{{- define "opentelemetry-collector.otlp.grpc.url" -}}
{{- if .Values.global.otlp.overrideGrpcURL -}}
    {{- print .Values.global.otlp.overrideGrpcURL -}}
{{- else if .Values.global.ingress.site -}}
    {{- include "incloud.otel.grpc.url" . -}}
{{- else if not .Values.global.backend.enabled -}}
    {{- fail "A valid global.ingress.site or global.otlp.overrideGrpcURL is required!" -}}
{{- else -}}
    {{- printf "%s:%d" (include "opentelemetry-collector.fullname" .) (index .Values.global "opentelemetry-collector" "ports" "otlp" "servicePort" | int ) -}}
{{- end -}}
{{- end -}}

{{- define "opentelemetry-collector.loki-historian.http.url" -}}
    {{- printf "%s://%s:%d" (include "opentelemetry-collector.otlp.scheme" .) (include "opentelemetry-collector.fullname" .) (index .Values.global "opentelemetry-collector" "ports" "loki-historian" "servicePort" | int ) -}}
{{- end -}}

{{- define "opentelemetry-collector.health.http.url" -}}
{{- $baseUrl := "" -}}
{{- if .Values.global.otlp.overrideHttpURL -}}
    {{- $baseUrl = .Values.global.otlp.overrideHttpURL -}}
{{- else if .Values.global.ingress.site -}}
    {{- $baseUrl = (include "incloud.otel.http.url" .) -}}
{{- else if not .Values.global.backend.enabled -}}
    {{- fail "A valid global.ingress.site or global.otlp.overrideHttpURL is required!" -}}
{{- else -}}
    {{- $baseUrl = (printf "%s://%s:%d" (include "opentelemetry-collector.otlp.scheme" .) (include "opentelemetry-collector.fullname" .) (index .Values.global "opentelemetry-collector" "ports" "health" "servicePort" | int )) -}}
{{- end -}}
{{- printf "%s/health" $baseUrl -}}
{{- end -}}

{{- define "opentelemetry-collector.datadogapm.base.http.url" -}}
{{- if .Values.global.datadogapm.overrideUrl -}}
    {{- .Values.global.datadogapm.overrideUrl -}}
{{- else if .Values.global.ingress.site -}}
    {{- include "incloud.otel.http.url" . -}}
{{- else if not .Values.global.backend.enabled -}}
    {{- fail "A valid global.ingress.site or global.datadogapm.overrideUrl is required!" -}}
{{- else -}}
    {{- printf "http://%s:%d" (include "opentelemetry-collector.fullname" .) (index .Values.global "opentelemetry-collector" "ports" "datadogapm" "servicePort" | int ) -}}
{{- end -}}
{{- end -}}

{{- define "opentelemetry-collector.datadogapm.tracesv03.http.url" -}}
{{- printf "%s/v0.3/traces" (include "opentelemetry-collector.datadogapm.base.http.url" .) -}}
{{- end -}}

{{- define "opentelemetry-collector.datadogapm.tracesv04.http.url" -}}
{{- printf "%s/v0.4/traces" (include "opentelemetry-collector.datadogapm.base.http.url" .) -}}
{{- end -}}

{{- define "opentelemetry-collector.datadogapm.tracesv05.http.url" -}}
{{- printf "%s/v0.5/traces" (include "opentelemetry-collector.datadogapm.base.http.url" .) -}}
{{- end -}}

{{- define "opentelemetry-collector.datadogapm.tracesv07.http.url" -}}
{{- printf "%s/v0.7/traces" (include "opentelemetry-collector.datadogapm.base.http.url" .) -}}
{{- end -}}

{{- define "opentelemetry-collector.datadogapm.tracesapiv02.http.url" -}}
{{- printf "%s/api/v0.2/traces" (include "opentelemetry-collector.datadogapm.base.http.url" .) -}}
{{- end -}}
