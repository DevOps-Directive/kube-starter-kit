{{- define "sensor.fullname" -}}
    {{- printf "%s-sensor" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "sensorDaemonSet.fullname" -}}
    {{- if .Values.agent.randomSuffixName -}}
        {{- printf "%s-%s" (include "sensor.fullname" . | trunc 58 ) (randAlphaNum 4 | lower) -}}
    {{- else -}}
        {{- include "sensor.fullname" . -}}
    {{- end -}}
{{- end -}}

{{- define "sensor.metric-ingestor-hostname" -}}
    {{- printf "%s-metric-ingestor" (include "sensor.fullname" .) -}}
{{- end -}}
{{- define "alligator.fullname" -}}
    {{- printf "%s-alligator" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}