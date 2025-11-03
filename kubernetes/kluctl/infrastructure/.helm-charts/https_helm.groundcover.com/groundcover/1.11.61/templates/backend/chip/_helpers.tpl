{{/*
CHIP helpers
*/}}

{{/*
CHIP worker name
*/}}
{{- define "chip.workerName" -}}
{{- printf "%s-clickhouse-ingestion-pipeline" .Release.Name -}}
{{- end -}}

{{/*
CHIP config map name
*/}}
{{- define "chip.configMapName" -}}
{{- printf "%s-config" (include "chip.workerName" .) -}}
{{- end -}}

{{/*
CHIP service account name
*/}}
{{- define "chip.serviceAccountName" -}}
{{- if .Values.chip.serviceAccount.name -}}
{{- .Values.chip.serviceAccount.name -}}
{{- else -}}
{{- include "chip.workerName" . -}}
{{- end -}}
{{- end -}}

{{/*
CHIP image
*/}}
{{- define "chip.image" -}}
{{- $registry := .Values.chip.image.registry | default "public.ecr.aws/groundcovercom" -}}
{{- $repository := .Values.chip.image.repository | default "chip" -}}
{{- $tag := required "A valid .Values.chip.image.tag is required when chip is enabled" .Values.chip.image.tag -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end -}}

{{/*
CHIP labels
*/}}
{{- define "chip.labels" -}}
app: {{ include "chip.workerName" . }}
component: worker
{{ include "groundcover.labels" . }}
{{- end -}}

{{/*
CHIP selector labels
*/}}
{{- define "chip.selectorLabels" -}}
app: {{ include "chip.workerName" . }}
component: worker
{{- end -}}
