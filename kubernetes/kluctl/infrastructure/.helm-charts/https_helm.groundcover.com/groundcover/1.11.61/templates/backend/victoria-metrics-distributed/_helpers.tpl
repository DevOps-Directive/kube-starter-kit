{{/*
Create the name for global ingest vmauth
backport https://github.com/VictoriaMetrics/helm-charts/pull/1520 into 0.4.2 (can drop once vm have released.)
*/}}
{{- define "victoria-metrics-distributed.vmauthIngestGlobalName" -}}
{{- printf "write-global-groundcover" -}}
{{- end }}

{{/*
Create the name for global query vmauth
backport https://github.com/VictoriaMetrics/helm-charts/pull/1520 into 0.4.2 (can drop once vm have released.)
*/}}
{{- define "victoria-metrics-distributed.vmauthQueryGlobalName" -}}
{{- printf "read-global-groundcover" }}
{{- end }}

{{- define "victoria-metrics-distributed.vmauthWriteBalancerUrl" -}}
{{- if and .Values.backend (index .Values.backend "victoria-metrics-distributed") (index .Values.backend "victoria-metrics-distributed" "availabilityZones") -}}
{{- $zone := (index (index .Values.backend "victoria-metrics-distributed" "availabilityZones") 0).name -}}
{{- printf "http://vmauth-vmauth-write-balancer-%s:8427/insert/0/prometheus/api/v1/write" $zone -}}
{{- end }} 
{{- end -}} 