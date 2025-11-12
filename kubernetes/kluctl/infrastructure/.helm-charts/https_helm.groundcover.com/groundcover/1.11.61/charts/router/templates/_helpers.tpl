{{/*
Expand the name of the chart.
*/}}
{{- define "router.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "router.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "router.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "router.labels" -}}
helm.sh/chart: {{ include "router.chart" . }}
{{ include "router.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: groundcover
{{ with .Values.additionalLabels }} 
{{- toYaml . -}}
{{- end }}
{{ with .Values.global.groundcoverLabels }} 
{{- toYaml . -}}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "router.selectorLabels" -}}
app.kubernetes.io/name: {{ include "router.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "router.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "router.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "router.imagePullSecrets" -}}
{{- .Values.imagePullSecrets | toJson -}}
{{- end -}}

{{- define "router.service.name" -}}
{{ print "router" }}
{{- end -}}

{{- define "router.proxy.service.name" -}}
{{ print "router-proxy" }}
{{- end -}}

{{- define "router.ws.url" -}}
{{ printf "ws://%s.%s.svc.cluster.local" (include "router.proxy.service.name" .) .Release.Namespace }}
{{- end -}}

{{- define "router.ds.url" -}}
{{ printf "https://%s.%s.svc.cluster.local" (include "router.proxy.service.name" .) .Release.Namespace }}
{{- end -}}

{{- define "router.repository" -}}
{{- if or (eq .Values.global.auth.type "no-auth") .Values.global.airgap }}
{{- printf "router-no-auth"  -}}
{{- else -}}
{{ printf "router"  -}}
{{- end -}}
{{- end -}}

{{- define "router.image" -}}
{{ printf "%s/%s:%s" .Values.origin.registry (tpl .Values.origin.repository .) .Values.origin.tag -}}
{{- end -}}

{{- define "router.jwt.secretName" -}}
{{ print "groundcover-jwt" }}
{{- end -}}

{{- define "router.jwt.secretKey" -}}
{{ print "private_key.pem" }}
{{- end -}}

{{- define "router.jwt.privateKey" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "router.jwt.secretName" .) | default dict) -}}
{{- if $secret -}}
    {{- index $secret "data" (include "router.jwt.secretKey" .) -}}
{{- else -}}
    {{- genPrivateKey "rsa" | b64enc -}}
{{- end -}}
{{- end -}}

{{- define "backendConfig.namespace" -}}
{{- if .Values.global.airgap -}}
{{- .Release.Namespace -}}
{{- else -}}
{{ print "groundcover-incloud" }}
{{- end -}}
{{- end -}}

{{- define "backendConfig.kongIngressClass" -}}
{{- if .Values.global.airgap -}}
{{ print "groundcover-kong" }}
{{- else -}}
{{ print "kong" }}
{{- end -}}
{{- end -}}

{{- define "backendConfig.shouldUpdateKongRouter" -}}
{{- if .Values.global.airgap -}}
{{ false }}
{{- else -}}
{{ true }}
{{- end -}}
{{- end -}}