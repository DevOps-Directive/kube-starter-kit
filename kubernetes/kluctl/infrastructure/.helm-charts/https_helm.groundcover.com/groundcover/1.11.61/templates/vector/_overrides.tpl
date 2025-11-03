{{/*
Expand the name of the chart.
*/}}
{{- define "vector.name" -}}
{{- print "vector" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vector.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "vector.name" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

# modified the PodSpec for Vector
# - add tpl to env and initContainers
# - add backendEnv to env if global.backend.enabled is true
# taken from chart v0.37, https://github.com/vectordotdev/helm-charts/blob/vector-0.37.0/charts/vector/templates/_pod.tpl

{{/*
Defines the PodSpec for Vector.
*/}}
{{- define "vector.pod" -}}
serviceAccountName: {{ include "vector.serviceAccountName" . }}
{{- with .Values.podHostNetwork }}
hostNetwork: {{ . }}
{{- end }}
{{- with .Values.podSecurityContext }}
securityContext:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.podPriorityClassName }}
priorityClassName: {{ . }}
{{- end }}
{{- with .Values.shareProcessNamespace }}
shareProcessNamespace: {{ . }}
{{- end }}
{{- with .Values.dnsPolicy }}
dnsPolicy: {{ . }}
{{- end }}
{{- with .Values.dnsConfig }}
dnsConfig:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.image.pullSecrets }}
imagePullSecrets:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.hostAliases }}
hostAliases:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.initContainers }}
initContainers:
  {{- tpl (toYaml .) $ | nindent 2 }}
{{- end }}
containers:
  - name: vector
{{- with .Values.securityContext }}
    securityContext:
{{ toYaml . | indent 6 }}
{{- end }}
{{- if .Values.image.sha }}
    image: "{{ .Values.image.repository }}:{{ include "vector.image.tag" . }}@sha256:{{ .Values.image.sha }}"
{{- else }}
    image: "{{ .Values.image.repository }}:{{ include "vector.image.tag" . }}"
{{- end }}
    imagePullPolicy: {{ .Values.image.pullPolicy }}
{{- with .Values.command }}
    command:
    {{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.args }}
    args:
    {{- toYaml . | nindent 6 }}
{{- end }}
    env:
      - name: VECTOR_LOG
        value: "{{ .Values.logLevel | default "info" }}"
{{- if .Values.global.backend.enabled -}}
{{- with .Values.backendEnv -}}
    {{- tpl (toYaml .) $ | nindent 6 }}
{{- end }}
{{- end }}
{{- /*
  predefined envs for object storage access keys
*/}}
{{  if and (not (empty .Values.objectStorage.s3Bucket)) (.Values.objectStorage.allowed) (not (empty .Values.objectStorage.accessKey))  }}
      - name: AWS_ACCESS_KEY_ID
        valueFrom:
          secretKeyRef:
            key: '{{ include "vector.s3.accessKey" . }}'
            name: '{{ include "vector.s3.secretName" . }}'
      - name: AWS_SECRET_ACCESS_KEY
        valueFrom:
          secretKeyRef:
            key: '{{ include "vector.s3.secretKey" . }}'
            name: '{{ include "vector.s3.secretName" . }}'
{{- end }}
{{- if .Values.env }}
{{- with .Values.env }}
    {{- tpl (toYaml .) $ | nindent 6 }}
{{- end }}
{{- end }}
{{- if (eq .Values.role "Agent") }}
      - name: VECTOR_SELF_NODE_NAME
        valueFrom:
          fieldRef:
            fieldPath: spec.nodeName
      - name: VECTOR_SELF_POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: VECTOR_SELF_POD_NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: PROCFS_ROOT
        value: "/host/proc"
      - name: SYSFS_ROOT
        value: "/host/sys"
{{- end }}
{{- if .Values.envFrom }}
{{- with .Values.envFrom }}
    envFrom:
    {{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
    ports:
{{- if or .Values.containerPorts .Values.existingConfigMaps }}
    {{- toYaml .Values.containerPorts | nindent 6 }}
{{- else if .Values.customConfig }}
    {{- include "vector.containerPorts" . | indent 6 }}
{{- else if or (eq .Values.role "Aggregator") (eq .Values.role "Stateless-Aggregator") }}
      - name: datadog-agent
        containerPort: 8282
        protocol: TCP
      - name: fluent
        containerPort: 24224
        protocol: TCP
      - name: logstash
        containerPort: 5044
        protocol: TCP
      - name: splunk-hec
        containerPort: 8080
        protocol: TCP
      - name: statsd
        containerPort: 8125
        protocol: TCP
      - name: syslog
        containerPort: 9000
        protocol: TCP
      - name: vector
        containerPort: 6000
        protocol: TCP
      - name: prom-exporter
        containerPort: 9090
        protocol: TCP
{{- else if (eq .Values.role "Agent") }}
      - name: prom-exporter
        containerPort: 9090
        protocol: TCP
{{- end }}
{{- with .Values.livenessProbe }}
    livenessProbe:
      {{- toYaml . | trim | nindent 6 }}
{{- end }}
{{- with .Values.readinessProbe }}
    readinessProbe:
      {{- toYaml . | trim | nindent 6 }}
{{- end }}
{{- with .Values.resources }}
    resources:
{{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.lifecycle }}
    lifecycle:
{{- toYaml . | nindent 6 }}
{{- end }}
    volumeMounts:
      - name: data
        {{- if .Values.existingConfigMaps }}
        mountPath: "{{ if .Values.dataDir }}{{ .Values.dataDir }}{{ else }}{{ fail "Specify `dataDir` if you're using `existingConfigMaps`" }}{{ end }}"
        {{- else }}
        mountPath: "{{ .Values.customConfig.data_dir | default "/vector-data-dir" }}"
        {{- end }}
      - name: config
        mountPath: "/etc/vector/"
        readOnly: true
{{- if (eq .Values.role "Agent") }}
{{- with .Values.defaultVolumeMounts }}
{{- toYaml . | nindent 6 }}
{{- end }}
{{- end }}
{{- with .Values.extraVolumeMounts }}
{{- toYaml . | nindent 6 }}
{{- end }}
{{- with .Values.extraContainers }}
{{ toYaml . | indent 2 }}
{{- end }}
terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
{{- with .Values.nodeSelector }}
nodeSelector:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with  .Values.topologySpreadConstraints }}
topologySpreadConstraints:
{{- toYaml . | nindent 2 }}
{{- end }}
volumes:
{{- if and .Values.persistence.enabled (eq .Values.role "Aggregator") }}
{{- with .Values.persistence.existingClaim }}
  - name: data
    persistentVolumeClaim:
      claimName: {{ . }}
{{- end }}
{{- else if (ne .Values.role "Agent") }}
  - name: data
    emptyDir: {}
{{- end }}
  - name: config
    projected:
      sources:
{{- if .Values.existingConfigMaps }}
  {{- range .Values.existingConfigMaps }}
        - configMap:
            name: {{ . }}
  {{- end }}
{{- else }}
        - configMap:
            name: {{ template "vector.fullname" . }}
{{- end }}
{{- if (eq .Values.role "Agent") }}
  - name: data
  {{- if .Values.persistence.hostPath.enabled }}
    hostPath:
      path: {{ .Values.persistence.hostPath.path | quote }}
  {{- else }}
    emptyDir: {}
  {{- end }}
    {{- with .Values.defaultVolumes }}
    {{- toYaml . | nindent 2 }}
    {{- end }}
{{- end }}
{{- with .Values.extraVolumes }}
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
