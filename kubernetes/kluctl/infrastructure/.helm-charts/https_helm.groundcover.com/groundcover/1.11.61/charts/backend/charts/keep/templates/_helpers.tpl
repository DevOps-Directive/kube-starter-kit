{{/*
Expand the name of the chart.
*/}}
{{- define "keep.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "keep.fullname" -}}
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
{{- define "keep.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "keep.labels" -}}
helm.sh/chart: {{ include "keep.chart" . }}
{{ include "keep.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: keep
{{- if .Values.additionalLabels }}
{{ toYaml .Values.additionalLabels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "keep.selectorLabels" -}}
app.kubernetes.io/name: {{ include "keep.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "keep.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "keep.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Helper function to find an environment variable in the list
*/}}
{{- define "keep.findEnvVar" -}}
{{- $name := index . 0 -}}
{{- $root := index . 1 -}}
{{- if and $root.Values.frontend $root.Values.frontend.env -}}
  {{- range $root.Values.frontend.env -}}
    {{- if eq .name $name -}}
      {{- .value -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Helper function to find an environment variable in the list
*/}}
{{- define "keep.findBackendEnvVar" -}}
{{- $name := index . 0 -}}
{{- $root := index . 1 -}}
{{- if and $root.Values.backend $root.Values.backend.env -}}
  {{- range $root.Values.backend.env -}}
    {{- if eq .name $name -}}
      {{- .value -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}


{{/*
Helper function for websocket host (relative)
*/}}
{{- define "keep.websocketPrefix" -}}
{{- coalesce .Values.global.ingress.websocketPrefix "/websocket" -}}
{{- end -}}

{{/*
Helper function for backend host (relative)
*/}}
{{- define "keep.backendPrefix" -}}
{{- coalesce .Values.global.ingress.backendPrefix "/api" -}}
{{- end -}}

{{/*
Helper function for frontend host (relative)
*/}}
{{- define "keep.frontendPrefix" -}}
{{- coalesce .Values.global.ingress.frontendPrefix "/" -}}
{{- end -}}

{{/*
Helper function for PUSHER_HOST
*/}}
{{- define "keep.pusherHost" -}}
{{- $pusherHost := include "keep.findEnvVar" (list "PUSHER_HOST" .) -}}
{{- if $pusherHost -}}
  {{- $pusherHost -}}
{{- else -}}
  {{- include "keep.websocketPrefix" . -}}
{{- end -}}
{{- end -}}

{{/*
Helper function for API_URL_CLIENT for the frontend
*/}}
{{- define "keep.apiUrlClient" -}}
{{- $apiUrlClient := include "keep.findEnvVar" (list "API_URL_CLIENT" .) -}}
{{- if $apiUrlClient -}}
  {{- $apiUrlClient -}}
{{- else -}}
  {{- if .Values.global.ingress.enabled -}}
    {{- include "keep.backendPrefix" . -}}
  {{- else -}}
    {{- print "/backend" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Helper function for API_URL
*/}}
{{- define "keep.apiUrl" -}}
{{- $apiUrl := include "keep.findEnvVar" (list "API_URL" .) -}}
{{- if $apiUrl -}}
  {{- $apiUrl -}}
{{- else -}}
  {{- printf "http://%s-backend:%v" (include "keep.fullname" .) (.Values.backend.service.port) -}}
{{- end -}}
{{- end -}}

{{/*
Expand the namespace of the release.
*/}}
{{- define "keep.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Helper function for getting the full URL (with protocol and host)
*/}}
{{- define "keep.fullUrl" -}}
{{- if and .Values.global.ingress.enabled .Values.global.ingress.hosts -}}
  {{- if .Values.global.ingress.tls -}}
    {{- $host := index .Values.global.ingress.hosts 0 -}}
    {{- printf "https://%s" $host.host -}}
  {{- else -}}
    {{- $host := index .Values.global.ingress.hosts 0 -}}
    {{- printf "http://%s" $host.host -}}
  {{- end -}}
{{- else -}}
  {{- print "http://localhost:3000" -}}
{{- end -}}
{{- end -}}

{{/*
Helper function for NEXTAUTH_URL
*/}}
{{- define "keep.nextAuthUrl" -}}
{{- $nextAuthUrl := include "keep.findEnvVar" (list "NEXTAUTH_URL" .) -}}
{{- if $nextAuthUrl -}}
    {{- $nextAuthUrl -}}
{{- else -}}
    {{- if .Values.global.ingress.enabled -}}
        {{- include "keep.fullUrl" . -}}
    {{- else -}}
        {{- print "http://localhost:3000" -}}
    {{- end -}}
{{- end -}}
{{- end -}}


{{/*
Helper function for KEEP_API_URL that handles both relative and absolute URLs
*/}}
{{- define "keep.keepApiUrl" -}}
{{- $backendApiUrl := include "keep.findBackendEnvVar" (list "KEEP_API_URL" .) -}}
{{- if $backendApiUrl -}}
    {{- $backendApiUrl -}}
{{- else -}}
    {{- $apiUrlClient := include "keep.apiUrlClient" . -}}
    {{- /* Check if the URL starts with http:// or https:// */ -}}
    {{- if or (hasPrefix "http://" $apiUrlClient) (hasPrefix "https://" $apiUrlClient) -}}
        {{- $apiUrlClient -}}
    {{- else -}}
        {{- include "keep.fullUrl" . -}}{{- $apiUrlClient -}}
    {{- end -}}
{{- end -}}
{{- end -}}
