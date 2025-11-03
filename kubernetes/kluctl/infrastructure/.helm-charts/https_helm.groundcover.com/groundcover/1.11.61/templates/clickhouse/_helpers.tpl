{{- define "clickhouse.fullname" -}}
{{- printf "%s-clickhouse" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "clickhouse.headlessServiceName" -}}
{{-  printf "%s-headless" (include "clickhouse.fullname" .) -}}
{{- end -}}

{{- define "clickhouse.database" -}}
{{-  print "groundcover" -}}
{{- end -}}

{{- define "clickhouse.username" -}}
{{-  print "default" -}}
{{- end -}}

{{- define "clickhouse.readerUsername" -}}
{{-  print "reader" -}}
{{- end -}}

{{- define "clickhouse.password" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "clickhouse.secretName" .) | default dict) -}}
{{- if .Values.global.clickhouse.auth.password -}}
    {{- .Values.global.clickhouse.auth.password -}}
{{- else if $secret -}}
    {{- index $secret "data" (include "clickhouse.secretKey" .) | b64dec -}}
{{- else -}}
    {{- randAlphaNum 16 -}}
{{- end -}}
{{- end -}}

{{- define "clickhouse.nativeEndpoint" -}}
{{-  printf "clickhouse://%s:%d" (include "clickhouse.fullname" .) (.Values.global.clickhouse.containerPorts.tcp | int ) -}}
{{- end -}}

{{- define "clickhouse.httpEndpoint" -}}
{{-  printf "http://%s:%d" (include "clickhouse.fullname" .) (.Values.global.clickhouse.containerPorts.http | int ) -}}
{{- end -}}

{{- define "clickhouse.shard0Name" -}}
{{ printf "%s-shard0-0-external" (include "clickhouse.fullname" $) }}
{{- end -}}

{{- define "clickhouse.shard0HttpEndpoint" -}}
{{ printf "http://%s:%d" (include "clickhouse.shard0Name" $) (.Values.global.clickhouse.containerPorts.http | int ) }}
{{- end -}}

{{- define "clickhouse.extraShardsList" -}}
{{- if kindIs "slice" .Values.dbManager.extraShardsOverride }}
{{- .Values.dbManager.extraShardsOverride | toYaml | nindent 2 }}
{{- else }}
{{- $shards := $.Values.clickhouse.shards | int }}
{{- $list := list -}}
{{- range $shard, $e := until $shards }}
{{- if ne $e 0}}
{{- $item := printf "%s-shard%d-%d-external" (include "clickhouse.fullname" $) $shard 0 }}
{{- $list = append $list $item }}
{{- end -}}
{{- end -}}
{{- $list | toYaml | nindent 2 }}
{{- end -}}
{{- end -}}

{{- define "clickhouse.opentelemetrySpanLogSetting" -}}
{{ if eq .Values.disableOpentelemetrySpanLog false }}
{{- else -}}
<opentelemetry_span_log remove="1"/>
{{- end -}}
{{- end -}}

