{{- define "kong.admin.url" -}}
{{- $host := printf "%s-admin.%s.svc.cluster.local" (include "kong.fullname" .) .Release.Namespace -}}
{{- if .Values.kong.admin.tls.enabled -}}
  {{ printf "https://%s:%d" $host (.Values.kong.admin.tls.containerPort | int) }}
{{- else if .Values.kong.admin.http.enabled -}}
  {{ printf "http://%s:%d" $host (.Values.kong.admin.http.containerPort | int) }}
{{- else -}}
  {{ fail "A valid .Values.admin.http.enabled=true or .Values.admin.tls.enabled=true is required!" }}
{{- end -}}
{{- end -}}

{{- define "kong.proxy.service.name" -}}
{{ printf "%s-proxy" (include "kong.fullname" .) }}
{{- end -}}

{{- define "kong.proxy.url" -}}
{{ printf "https://%s.%s.svc.cluster.local" (include "kong.proxy.service.name" .) .Release.Namespace }}
{{- end -}}
