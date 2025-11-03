{{- define "custom-metrics.server.fullname" -}}
    {{- printf "%s-custom-metrics" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "custom-metrics.base.http.url" -}}
    {{- printf "http://%s:%d" (include "custom-metrics.server.fullname" .) (8429) -}}
{{- end -}}

{{- define "custom-metrics.write.http.url" -}}
    {{- printf "%s/api/v1/write" (include "custom-metrics.base.http.url" .) -}}
{{- end -}}

{{- define "custom-metrics.remote-sensor-server-url" -}}
    {{- printf "http://%s:%d/api/v1/write" (include "sensor.metric-ingestor-hostname" .) 8428 -}}
{{- end -}}

{{- define "custom-metrics.remote-server-url" -}}
    {{- if .Values.useSensorAsEndpoint -}}
        {{- printf "%s" (include "custom-metrics.remote-sensor-server-url" .) -}}
    {{- else -}}
        {{- printf "%s" (include "victoria-metrics.write.http.url" .) }}
    {{- end -}}
{{- end -}}