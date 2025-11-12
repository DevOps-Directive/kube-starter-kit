{{- define "groundcover.sensor.receivers.remotewrite.enabled" -}}
  {{- if .sensorValues.metricIngestor -}}
    {{- .sensorValues.metricIngestor.serverEnabled -}}
  {{- else -}}
    {{- .sensorValues.receivers.remotewrite.enabled -}}
  {{- end -}}
{{- end -}}

{{- define "groundcover.sensor.receivers.remotewrite.port" -}}
  {{- if .sensorValues.metricIngestor -}}
    {{- .sensorValues.metricIngestor.serverPort -}}
  {{- else -}}
    {{- .sensorValues.receivers.remotewrite.port -}}
  {{- end -}}
{{- end -}}

{{- define "groundcover.sensor.config.deprecated" -}}
{{- if .sensorValues.metricIngestor -}}
metricIngestor:
  {{ if .sensorValues.ingestionEnabled }}
  serverEnabled: {{ .sensorValues.metricIngestor.serverEnabled }}
  serverPort: {{ .sensorValues.metricIngestor.serverPort }}
  {{ end }}
  {{ if .sensorValues.collectionEnabled }}
  scraperEnabled: {{ .sensorValues.metricIngestor.scraperEnabled }}
  maxScrapeSize: {{ .sensorValues.metricIngestor.maxScrapeSize }}
  {{ end }}
  usePrometheusCompatibleNaming: {{ .sensorValues.metricIngestor.usePrometheusCompatibleNaming }}
{{- end -}}
{{- end -}}

{{- define "groundcover.sensor.config" -}}
{{- $sensorValues := .sensorValues -}}

# Include the deprecated configuration to make sensor log and metricate when deprecated config is used
{{ include "groundcover.sensor.config.deprecated" . }}

serviceName: {{ $sensorValues.serviceName }}
alligatorConfigurationExists: {{ or $sensorValues.alligatorConfigurationExists false }} 
healthProbe:
  enabled: {{ $sensorValues.healthProbe.enabled }}
  port: {{ $sensorValues.healthProbe.port }}
receivers:
  {{ if $sensorValues.ingestionEnabled }}
  remotewrite:
    enabled: {{ $sensorValues.receivers.remotewrite.enabled }}
    port: {{ $sensorValues.receivers.remotewrite.port }}
  {{ end }}
  {{ if $sensorValues.collectionEnabled }}
  metricsscraper:
    enabled: {{ $sensorValues.receivers.metricsscraper.enabled }}
    maxScrapeSize: {{ $sensorValues.receivers.metricsscraper.maxScrapeSize }}
  {{ end }}
exporters:
  remotewrite:
    url: {{ if $sensorValues.exporters.remotewrite.url }}{{ tpl $sensorValues.exporters.remotewrite.url . }}{{ else }}{{ include "metrics-ingester.write.http.url" . }}{{ end }}
    usePrometheusCompatibleNaming: {{ $sensorValues.exporters.remotewrite.usePrometheusCompatibleNaming }}
    tlsSkipVerify: true
    maxDiskUsagePerURL: {{ $sensorValues.exporters.remotewrite.maxDiskUsagePerURL }}
    tmpDataPath: {{ $sensorValues.exporters.remotewrite.tmpDataPath }}
pipelines:
  metrics:
    enricherEnabled: {{ $sensorValues.pipelines.metrics.enricherEnabled }}
    {{- if $sensorValues.pipelines.metrics.aggregation }}
    aggregation:
      enabled: {{ $sensorValues.pipelines.metrics.aggregation.enabled }}
      {{- if $sensorValues.pipelines.metrics.aggregation.configuration }}
      configuration:
        dedupInterval: {{ $sensorValues.pipelines.metrics.aggregation.configuration.dedupInterval }}
        dropInput: {{ $sensorValues.pipelines.metrics.aggregation.configuration.dropInput }}
        {{- if $sensorValues.pipelines.metrics.aggregation.configuration.dropInputLabels }}
        dropInputLabels: {{ toYaml $sensorValues.pipelines.metrics.aggregation.configuration.dropInputLabels | nindent 10 }}
        {{- end }}
        ignoreOldSamples: {{ $sensorValues.pipelines.metrics.aggregation.configuration.ignoreOldSamples }}
        ignoreFirstIntervals: {{ $sensorValues.pipelines.metrics.aggregation.configuration.ignoreFirstIntervals }}
        keepInput: {{ $sensorValues.pipelines.metrics.aggregation.configuration.keepInput }}
        enableWindows: {{ $sensorValues.pipelines.metrics.aggregation.configuration.enableWindows }}
        content: {{ $sensorValues.pipelines.metrics.aggregation.configuration.content | quote }}
      {{- end }}
    {{- end }}
startuptimeout: 120s
{{ if $sensorValues.collectionEnabled }}
productchansize: 512
pushsummaries: true
productmetricsflushmintotalcounter:
  http: 1
  redis: 1
  amqp: 1
  sql: 1
  kafka: 1
  dns: 1
  grpc: 1
  mongodb: 1
  node_info: 1
  container_crash: 1
  container_info: 1
  container_state: 1
  container_oomkill: 1
  pvc_info: 1

httphandler:
  samplesthreshold: 10
  issuesthreshold: 10
  sampling:
    samplingmode: 1 # DefaultSample
    samplingLimitMaxQueue: 0
    samplingLimitAgeOut: 0s
  {{ if and $sensorValues.httphandler $sensorValues.httphandler.truncationConfig }}
  truncationConfig:
    enabled: {{ coalesce $sensorValues.noPayloadsMode $sensorValues.httphandler.truncationConfig.enabled }}
    payloadSizeLimit: {{ ternary 0 $sensorValues.httphandler.truncationConfig.payloadSizeLimit $sensorValues.noPayloadsMode }}
  {{ end }}
  {{ if and $sensorValues.httphandler $sensorValues.httphandler.obfuscationConfig }}
  obfuscationConfig:
    {{ if and $sensorValues.httphandler $sensorValues.httphandler.obfuscationConfig.keyValueConfig }}
    keyValueConfig:
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.httphandler.obfuscationConfig.keyValueConfig.enabled }}
      caseSensitive: {{ $sensorValues.httphandler.obfuscationConfig.keyValueConfig.caseSensitive }}
      mode: {{ $sensorValues.httphandler.obfuscationConfig.keyValueConfig.mode }} 
      specificKeys: {{ $sensorValues.httphandler.obfuscationConfig.keyValueConfig.specificKeys | toJson }}
    {{ end }}
    {{ if and $sensorValues.httphandler $sensorValues.httphandler.obfuscationConfig.unstructuredConfig }}
    unstructuredConfig: 
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.httphandler.obfuscationConfig.unstructuredConfig.enabled }}
    {{ end }}
  {{ end }}
  interval: 30s
  summarizerActiveTtl: 45s
  aggregationCacheSize: 4096

grpchandler:
  samplesthreshold: 10
  issuesthreshold: 10
  sampling:
    samplingmode: 1 # DefaultSample
    samplingLimitMaxQueue: 0
    samplingLimitAgeOut: 0s
  {{ if and $sensorValues.grpchandler $sensorValues.grpchandler.truncationConfig }}
  truncationConfig:
    enabled: {{ coalesce $sensorValues.noPayloadsMode $sensorValues.grpchandler.truncationConfig.enabled }}
    payloadSizeLimit: {{ ternary 0 $sensorValues.grpchandler.truncationConfig.payloadSizeLimit $sensorValues.noPayloadsMode }}
  {{ end }}
  {{ if and $sensorValues.grpchandler $sensorValues.grpchandler.obfuscationConfig }}
  obfuscationConfig:
    {{ if and $sensorValues.grpchandler $sensorValues.grpchandler.obfuscationConfig.keyValueConfig }}
    keyValueConfig:
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.grpchandler.obfuscationConfig.keyValueConfig.enabled }}
      caseSensitive: {{ $sensorValues.grpchandler.obfuscationConfig.keyValueConfig.caseSensitive }}
      mode: {{ $sensorValues.grpchandler.obfuscationConfig.keyValueConfig.mode }}
      specificKeys: {{ $sensorValues.grpchandler.obfuscationConfig.keyValueConfig.specificKeys | toJson }}
    {{ end }}
    {{ if and $sensorValues.grpchandler $sensorValues.grpchandler.obfuscationConfig.unstructuredConfig }}
    unstructuredConfig: 
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.grpchandler.obfuscationConfig.unstructuredConfig.enabled }}
    {{ end }}
  {{ end }}
  interval: 30s
  summarizerActiveTtl: 45s
  aggregationCacheSize: 4096

redishandler:
  samplesthreshold: 10
  issuesthreshold: 10
  sampling:
    samplingmode: 1 # DefaultSample
    samplingLimitMaxQueue: 0
    samplingLimitAgeOut: 0s
  {{ if and $sensorValues.redishandler $sensorValues.redishandler.truncationConfig }}
  truncationConfig:
    enabled: {{ coalesce $sensorValues.noPayloadsMode $sensorValues.redishandler.truncationConfig.enabled }}
    payloadSizeLimit: {{ ternary 0 $sensorValues.redishandler.truncationConfig.payloadSizeLimit $sensorValues.noPayloadsMode }}
  {{ end }}
  {{ if and $sensorValues.redishandler $sensorValues.redishandler.obfuscationConfig }}
  obfuscationConfig:
    {{ if and $sensorValues.redishandler $sensorValues.redishandler.obfuscationConfig.keyValueConfig }}
    keyValueConfig:
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.redishandler.obfuscationConfig.keyValueConfig.enabled }}
      caseSensitive: {{ $sensorValues.redishandler.obfuscationConfig.keyValueConfig.caseSensitive }}
      mode: {{ $sensorValues.redishandler.obfuscationConfig.keyValueConfig.mode }} 
      specificKeys: {{ $sensorValues.redishandler.obfuscationConfig.keyValueConfig.specificKeys | toJson }}
    {{ end }}
    {{ if and $sensorValues.redishandler $sensorValues.redishandler.obfuscationConfig.unstructuredConfig }}
    unstructuredConfig: 
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.redishandler.obfuscationConfig.unstructuredConfig.enabled }}
    {{ end }}
  {{ end }}
  interval: 30s
  summarizerActiveTtl: 45s
  aggregationCacheSize: 4096
  obfuscateSensitiveValues: {{ $sensorValues.redishandler.obfuscateSensitiveValues }}

amqphandler:
  samplesthreshold: 10
  issuesthreshold: 10
  sampling:
    samplingmode: 1 # DefaultSample
    samplingLimitMaxQueue: 0
    samplingLimitAgeOut: 0s
  {{ if and $sensorValues.amqphandler $sensorValues.amqphandler.truncationConfig }}
  truncationConfig:
    enabled: {{ coalesce $sensorValues.noPayloadsMode $sensorValues.amqphandler.truncationConfig.enabled }}
    payloadSizeLimit: {{ ternary 0 $sensorValues.amqphandler.truncationConfig.payloadSizeLimit $sensorValues.noPayloadsMode }}
  {{ end }}
  {{ if and $sensorValues.amqphandler $sensorValues.amqphandler.obfuscationConfig }}
  obfuscationConfig:
    {{ if and $sensorValues.amqphandler $sensorValues.amqphandler.obfuscationConfig.keyValueConfig }}
    keyValueConfig:
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.amqphandler.obfuscationConfig.keyValueConfig.enabled }}
      caseSensitive: {{ $sensorValues.amqphandler.obfuscationConfig.keyValueConfig.caseSensitive }}
      mode: {{ $sensorValues.amqphandler.obfuscationConfig.keyValueConfig.mode }} 
      specificKeys: {{ $sensorValues.amqphandler.obfuscationConfig.keyValueConfig.specificKeys | toJson }}
    {{ end }}
    {{ if and $sensorValues.amqphandler $sensorValues.amqphandler.obfuscationConfig.unstructuredConfig }}
    unstructuredConfig: 
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.amqphandler.obfuscationConfig.unstructuredConfig.enabled }}
    {{ end }}
  {{ end }}
  interval: 30s
  summarizerActiveTtl: 45s
  aggregationCacheSize: 4096

sqlhandler:
  samplesthreshold: 10
  issuesthreshold: 10
  sampling:
    samplingmode: 1 # DefaultSample
    samplingLimitMaxQueue: 0
    samplingLimitAgeOut: 0s
  {{ if and $sensorValues.sqlhandler $sensorValues.sqlhandler.truncationConfig }}
  truncationConfig:
    enabled: {{ coalesce $sensorValues.noPayloadsMode $sensorValues.sqlhandler.truncationConfig.enabled }}
    payloadSizeLimit: {{ ternary 0 $sensorValues.sqlhandler.truncationConfig.payloadSizeLimit $sensorValues.noPayloadsMode }}
  {{ end }}
  {{ if and $sensorValues.sqlhandler $sensorValues.sqlhandler.obfuscationConfig }}
  obfuscationConfig:
    {{ if and $sensorValues.sqlhandler $sensorValues.sqlhandler.obfuscationConfig.keyValueConfig }}
    keyValueConfig:
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.sqlhandler.obfuscationConfig.keyValueConfig.enabled }}
      caseSensitive: {{ $sensorValues.sqlhandler.obfuscationConfig.keyValueConfig.caseSensitive }}
      mode: {{ $sensorValues.sqlhandler.obfuscationConfig.keyValueConfig.mode }} 
      specificKeys: {{ $sensorValues.sqlhandler.obfuscationConfig.keyValueConfig.specificKeys | toJson }}
    {{ end }}
    {{ if and $sensorValues.sqlhandler $sensorValues.sqlhandler.obfuscationConfig.unstructuredConfig }}
    unstructuredConfig: 
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.sqlhandler.obfuscationConfig.unstructuredConfig.enabled }}
    {{ end }}
  {{ end }}
  interval: 30s
  summarizerActiveTtl: 45s
  aggregationCacheSize: 4096

kafkahandler:
  samplesthreshold: 10
  issuesthreshold: 10
  sampling:
    samplingmode: 1 # DefaultSample
    samplingLimitMaxQueue: 10
    samplingLimitAgeOut: 1s
  {{ if and $sensorValues.kafkahandler $sensorValues.kafkahandler.truncationConfig }}
  truncationConfig:
    enabled: {{ coalesce $sensorValues.noPayloadsMode $sensorValues.kafkahandler.truncationConfig.enabled }}
    payloadSizeLimit: {{ ternary 0 $sensorValues.kafkahandler.truncationConfig.payloadSizeLimit $sensorValues.noPayloadsMode }}
  {{ end }}
  {{ if and $sensorValues.kafkahandler $sensorValues.kafkahandler.obfuscationConfig }}
  obfuscationConfig:
    {{ if and $sensorValues.kafkahandler $sensorValues.kafkahandler.obfuscationConfig.keyValueConfig }}
    keyValueConfig:
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.kafkahandler.obfuscationConfig.keyValueConfig.enabled }}
      caseSensitive: {{ $sensorValues.kafkahandler.obfuscationConfig.keyValueConfig.caseSensitive }}
      mode: {{ $sensorValues.kafkahandler.obfuscationConfig.keyValueConfig.mode }} 
      specificKeys: {{ $sensorValues.kafkahandler.obfuscationConfig.keyValueConfig.specificKeys | toJson }}
    {{ end }}
    {{ if and $sensorValues.kafkahandler $sensorValues.kafkahandler.obfuscationConfig.unstructuredConfig }}
    unstructuredConfig: 
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.kafkahandler.obfuscationConfig.unstructuredConfig.enabled }}
    {{ end }}
  {{ end }}
  interval: 30s
  summarizerActiveTtl: 45s
  aggregationCacheSize: 4096

dnshandler:
  samplesthreshold: 10
  issuesthreshold: 10
  sampling:
    samplingmode: 1 # DefaultSample
    samplingLimitMaxQueue: 10
    samplingLimitAgeOut: 1s
  {{ if and $sensorValues.dnshandler $sensorValues.dnshandler.truncationConfig }}
  truncationConfig:
    enabled: {{ coalesce $sensorValues.noPayloadsMode $sensorValues.dnshandler.truncationConfig.enabled }}
    payloadSizeLimit: {{ ternary 0 $sensorValues.dnshandler.truncationConfig.payloadSizeLimit $sensorValues.noPayloadsMode }}
  {{ end }}
  {{ if and $sensorValues.dnshandler $sensorValues.dnshandler.obfuscationConfig }}
  obfuscationConfig:
    {{ if and $sensorValues.dnshandler $sensorValues.dnshandler.obfuscationConfig.keyValueConfig }}
    keyValueConfig:
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.dnshandler.obfuscationConfig.keyValueConfig.enabled }}
      caseSensitive: {{ $sensorValues.dnshandler.obfuscationConfig.keyValueConfig.caseSensitive }}
      mode: {{ $sensorValues.dnshandler.obfuscationConfig.keyValueConfig.mode }} 
      specificKeys: {{ $sensorValues.dnshandler.obfuscationConfig.keyValueConfig.specificKeys | toJson }}
    {{ end }}
    {{ if and $sensorValues.dnshandler $sensorValues.dnshandler.obfuscationConfig.unstructuredConfig }}
    unstructuredConfig: 
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.dnshandler.obfuscationConfig.unstructuredConfig.enabled }}
    {{ end }}
  {{ end }}
  interval: 30s
  summarizerActiveTtl: 45s
  aggregationCacheSize: 300

mongodbhandler:
  samplesthreshold: 10
  issuesthreshold: 10
  sampling:
    samplingmode: 1 # DefaultSample
    samplingLimitMaxQueue: 0
    samplingLimitAgeOut: 0s
  {{ if and $sensorValues.mongodbhandler $sensorValues.mongodbhandler.truncationConfig }}
  truncationConfig:
    enabled: {{ coalesce $sensorValues.noPayloadsMode $sensorValues.mongodbhandler.truncationConfig.enabled }}
    payloadSizeLimit: {{ ternary 0 $sensorValues.mongodbhandler.truncationConfig.payloadSizeLimit $sensorValues.noPayloadsMode }}
  {{ end }}
  {{ if and $sensorValues.mongodbhandler $sensorValues.mongodbhandler.obfuscationConfig }}
  obfuscationConfig:
    {{ if and $sensorValues.mongodbhandler $sensorValues.mongodbhandler.obfuscationConfig.keyValueConfig }}
    keyValueConfig:
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.mongodbhandler.obfuscationConfig.keyValueConfig.enabled }}
      caseSensitive: {{ $sensorValues.mongodbhandler.obfuscationConfig.keyValueConfig.caseSensitive }}
      mode: {{ $sensorValues.mongodbhandler.obfuscationConfig.keyValueConfig.mode }} 
      specificKeys: {{ $sensorValues.mongodbhandler.obfuscationConfig.keyValueConfig.specificKeys | toJson }}
    {{ end }}
    {{ if and $sensorValues.mongodbhandler $sensorValues.mongodbhandler.obfuscationConfig.unstructuredConfig }}
    unstructuredConfig: 
      enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.mongodbhandler.obfuscationConfig.unstructuredConfig.enabled }}
    {{ end }}
  {{ end }}
  interval: 30s
  summarizerActiveTtl: 45s
  aggregationCacheSize: 4096

containerInfoHandler:
  samplesthreshold: 10
  issuesthreshold: 10
  sampling:
    samplingmode: 0 # DontSample
    samplingLimitMaxQueue: 0
    samplingLimitAgeOut: 0s
  interval: 30s
  summarizerActiveTtl: 45s
  aggregationCacheSize: 4096

pvcIoHandler:
  sampling:
    samplingmode: 0 # DontSample
  interval: 10s
  summarizerActiveTtl: 90s
  aggregationCacheSize: 4096

l4MetricsHandler:
  sampling:
    samplingmode: 0 # DontSample
  interval: 10s
  summarizerActiveTtl: 90s
  aggregationCacheSize: 10240

containerStateHandler:
  samplesthreshold: 10
  issuesthreshold: 10
  sampling:
    samplingmode: 0 # DontSample
    samplingLimitMaxQueue: 0
    samplingLimitAgeOut: 0s
  interval: 30s
  summarizerActiveTtl: 45s
  aggregationCacheSize: 4096

containercrashhandler:
  sampling:
    samplingmode: 0 # DontSample
  interval: 30s
  summarizerActiveTtl: 0
  aggregationCacheSize: 1024

pvcinfohandler:
  samplesthreshold: 20
  issuesthreshold: 20
  sampling:
    samplingmode: 0 # DontSample
    samplingLimitMaxQueue: 0
    samplingLimitAgeOut: 0s
  interval: 1m0s
  summarizerActiveTtl: 45s
  aggregationCacheSize: 1024

pidcache:
  expiration: 5m
  purge: 20s
{{ end }}

cluster:
  maxhosts: 10000
  maxchildrens: 40
  childcountruleoverrides: {{ toJson $sensorValues.childcountruleoverrides }}

loglevel: 4 # INFO

{{ if $sensorValues.collectionEnabled }}
isk8s: {{.Values.isk8s }}
{{ end }}

allowedportspercontainer: 20
{{ if $sensorValues.collectionEnabled }}
k8smetricsfetcher:
  fetchinterval: 15s
  requesttimeout: 10s
  fetchKubeletInfraMetrics: {{ .Values.fetchKubeletInfraMetrics }}
{{ end }}

{{ if $sensorValues.collectionEnabled }}
piiDetector:
  enabled: true
  sizeLimit: 1024
{{ end }}

globallimiter:
  maxqueue: 20
  ageout: 100ms
  sampleeverything: false

watchOnlyLocalNode: {{ $sensorValues.watchOnlyLocalNode }}
{{ if $sensorValues.collectionEnabled }}
floraEnabled: true
{{ end }}
collectionEnabled: {{ $sensorValues.collectionEnabled }}
ingestionEnabled: {{ $sensorValues.ingestionEnabled }}
runningNamespace: ""
{{ if $sensorValues.collectionEnabled }}
shouldDropRunningNamespaces: {{ include "groundcover.shouldDropRunningNamespaces" . }}
tracesNamespaceFilters: {{ toYaml .Values.tracesNamespaceFilters | nindent 2 }}
tracesWorkloadFilters: {{ toYaml .Values.tracesWorkloadFilters | nindent 2 }}
nodelabels: {{ toYaml $sensorValues.nodelabels | nindent 2 }}
contentTypesToDrop: {{ toYaml $sensorValues.contentTypesToDrop | nindent 2 }}
contentTypesWithoutClustering: {{ toYaml $sensorValues.contentTypesWithoutClustering | nindent 2 }}
hostHeadersToDrop: {{ toYaml $sensorValues.hostHeadersToDrop | nindent 2 }}
headersForceSampling: {{ toYaml $sensorValues.headersForceSampling | nindent 2 }}
customEntityTags: {{ toYaml $sensorValues.customEntityTags | nindent 2 }}
sendKubeletInfraMetrics: {{ .Values.sendKubeletInfraMetrics }}
{{ end }}

{{ if $sensorValues.ingestionEnabled }}
apmIngestor: 
  tracesOtlpEndpoint:
    endpoint: {{ include "ingestion.traces.otlp.http.url" . }}
    insecureSkipVerify: {{ .Values.global.ingestion.tls_skip_verify }}
    writeTimeout: 10s
    batchSize: 100
    flushInterval: 30s
  logsOtlpEndpoint:
    endpoint: {{ include "ingestion.logs.otlp.http.url" . }}
    insecureSkipVerify: {{ .Values.global.ingestion.tls_skip_verify }}
    writeTimeout: 10s
    batchSize: 100
    flushInterval: 30s
  dataDog:
    proxyEnabled: {{ $sensorValues.apmIngestor.dataDog.proxyEnabled }}
    enabled: {{ $sensorValues.apmIngestor.dataDog.enabled }}
    endpoint: {{ include "opentelemetry-collector.datadogapm.base.http.url" . }}
    tracesPort: {{ $sensorValues.apmIngestor.dataDog.tracesPort }}
    samplingRatio: {{ $sensorValues.apmIngestor.dataDog.samplingRatio }}
    handleTraces: {{ $sensorValues.apmIngestor.dataDog.handleTraces }}
    handleStats: {{ $sensorValues.apmIngestor.dataDog.handleStats }}
  otel:
    proxyEnabled: {{ $sensorValues.apmIngestor.otel.proxyEnabled }}
    direct:
      enabled: {{ $sensorValues.apmIngestor.otel.direct.enabled }}
      {{- if $sensorValues.apmIngestor.otel.direct.resourceProcessor }}
      resourceProcessor:
{{ toYaml $sensorValues.apmIngestor.otel.direct.resourceProcessor | indent 8 }}
      {{- end }}
      samplingRatio: {{ $sensorValues.apmIngestor.otel.direct.samplingRatio }}
      zipkin:
        enabled: {{ $sensorValues.apmIngestor.otel.direct.zipkin.enabled }}
        port: {{ $sensorValues.apmIngestor.otel.direct.zipkin.port }}
      otlp:
        enabled: {{ $sensorValues.apmIngestor.otel.direct.otlp.enabled }}
        grpcPort: {{ $sensorValues.apmIngestor.otel.direct.otlp.grpcPort }}
        httpPort: {{ $sensorValues.apmIngestor.otel.direct.otlp.httpPort }}
        maxRecvMsgSizeMiB: {{ $sensorValues.apmIngestor.otel.direct.otlp.maxRecvMsgSizeMiB }}
      jaeger:
        enabled: {{ $sensorValues.apmIngestor.otel.direct.jaeger.enabled }}
        grpcPort: {{ $sensorValues.apmIngestor.otel.direct.jaeger.grpcPort }}
        thriftHttpPort: {{ $sensorValues.apmIngestor.otel.direct.jaeger.thriftHttpPort }}
        thriftBinaryPort: {{ $sensorValues.apmIngestor.otel.direct.jaeger.thriftBinaryPort }}
        thriftCompactPort: {{ $sensorValues.apmIngestor.otel.direct.jaeger.thriftCompactPort }}
      httpjson:
        enabled: {{ $sensorValues.apmIngestor.otel.direct.httpjson.enabled }}
        port: {{ $sensorValues.apmIngestor.otel.direct.httpjson.port }}
      firehose:
        enabled: {{ $sensorValues.apmIngestor.otel.direct.firehose.enabled }}
        port: {{ $sensorValues.apmIngestor.otel.direct.firehose.port }}
      loki:
        enabled: {{ $sensorValues.apmIngestor.otel.direct.loki.enabled }}
        port: {{ $sensorValues.apmIngestor.otel.direct.loki.port }}
      rum:
        enabled: {{ $sensorValues.apmIngestor.otel.direct.rum.enabled }}
        port: {{ $sensorValues.apmIngestor.otel.direct.rum.port }}
{{ end }}
pprof:
  enabled: {{ include "telemetry.enabled" . }}
  cpuSamplingDuration: {{ $sensorValues.pprof.cpuSamplingDuration }}
  httpUploader:
    enabled: {{ eq $sensorValues.pprof.uploaderType "http" }}
    pushURL: {{ printf "%s/upload/pprof" (include "telemetry.metrics.base.url" .) }}
  pyroscopeUploader:
    enabled: {{ eq $sensorValues.pprof.uploaderType "pyroscope" }}
    pushURL: {{ include "telemetry.metrics.base.url" . }}
  backoffTicker:
    interval: {{ $sensorValues.pprof.backoffTicker.interval }}
    exponent: {{ $sensorValues.pprof.backoffTicker.exponent }}
  memoryTicker:
    enabled: {{ $sensorValues.pprof.memoryTicker.enabled }}
    interval: {{ $sensorValues.pprof.memoryTicker.interval }}
    jumpSizeInBytes: {{ $sensorValues.pprof.memoryTicker.jumpSizeInBytes }}
    windowSize: {{ $sensorValues.pprof.memoryTicker.windowSize }}
    initialWait: {{ $sensorValues.pprof.memoryTicker.initialWait }}
  cpuTicker:
    enabled: {{ $sensorValues.pprof.cpuTicker.enabled }}
    interval: {{ $sensorValues.pprof.cpuTicker.interval }}
    jumpSizeInMCPU: {{ $sensorValues.pprof.cpuTicker.jumpSizeInMCPU }}
    windowSize: {{ $sensorValues.pprof.cpuTicker.windowSize }}
    initialWait: {{ $sensorValues.pprof.cpuTicker.initialWait }}

clusterId: {{ include "groundcover.clusterId" . }}
region: {{ .Values.region }}
env: {{ include "groundcover.env" . }}
envType: {{ .Values.env_type }}

fleetClientConfig:
  enabled: {{ .Values.global.fleetmanager.enabled }}
  url: {{ include "fleet-manager.url.legacy" . }}
  requestIntervalEnabled: {{ .Values.fleetClientConfig.requestIntervalEnabled }}
  maximumInitialJitter: {{ .Values.fleetClientConfig.maximumInitialJitter }}
  requestInterval: {{ .Values.fleetClientConfig.requestInterval }}
  initialUpdateTimeout: {{ .Values.fleetClientConfig.initialUpdateTimeout }}

logs:
  {{ if $sensorValues.collectionEnabled }}
  scraper:
    positionsFile: {{ .Values.positionsFile }}
    positionsSyncInterval: 10s
    targetSyncInterval: 5s
    dockerMaxLogSize: {{ .Values.maxLogSize }}
    journalConfig: {{ toYaml .Values.journalScraper | nindent 6 }}
    logFileTargets: {{ toYaml .Values.logFileTargets | nindent 6 }}
  {{ end }}
  client:
    batchwait: 5000ms
    batchsize: 10485760
    backoffConfig:
      minBackoff: 500ms
      maxBackoff: 5m
      maxRetries: 10
    externalLabels:
      labelSet:
        cluster_id: {{ include "groundcover.clusterId" . }}
        env_name: {{ include "groundcover.env" . }}
        gc_env_type: {{ .Values.env_type }}
        job: sensor
    timeout: 10s
    useRingBuffer: false
    dropRunningNamespaceLogs: {{  include "groundcover.dropRunningNamespaceLogs" .}}
    logBatchSendQueueWorkerCount: {{ .Values.logBatchSendQueueWorkerCount }} 
    logBatchSendQueueMaxSize : {{ .Values.logBatchSendQueueMaxSize }}
    otlpExportLimits:
      jsonFlattenMaxDepth: {{ .Values.jsonFlattenMaxDepth }}
      jsonFlattenMaxAttributes: {{ .Values.jsonFlattenMaxAttributes }}
      maxLogContentSize: {{ .Values.maxLogContentSize }}
    logPatternsConfig:
      enabled: {{ .Values.logPatternsConfig.enabled }}
      logClusterDepth: {{ .Values.logPatternsConfig.logClusterDepth }}
      similarityThreshold: {{ .Values.logPatternsConfig.similarityThreshold }}
      maxChildren: {{ .Values.logPatternsConfig.maxChildren }}
      maxClusters: {{ .Values.logPatternsConfig.maxClusters }}
      paramString: {{ .Values.logPatternsConfig.paramString }}
      maxEvictionRatio: {{ .Values.logPatternsConfig.maxEvictionRatio }}
      maxTokens: {{ .Values.logPatternsConfig.maxTokens }}
      maxContentLength : {{ .Values.logPatternsConfig.maxContentLength }}
      containerIdCacheMaxSize : {{ .Values.logPatternsConfig.containerIdCacheMaxSize }}
      containerIdCacheTTL : {{ .Values.logPatternsConfig.containerIdCacheTTL }}
      summarizerConfig: {{ toYaml .Values.logPatternsConfig.summarizerConfig | nindent 8 }}
    ottlRules: {{ toYaml .Values.ottlRules | nindent 6 }}
  pipeline:
    logDropFilters: {{ toYaml .Values.logsDropFilters | nindent 6}}
    multiLineConfigs: {{ toYaml .Values.logsMultiLines | nindent 6}}
    grokParserConfig: {{ toYaml .Values.grokParserConfig | nindent 6}}
    decolorize: {{ .Values.decolorizeLogs }}
    maxLogSize: {{ .Values.maxLogSize }}
    oldLogDropThreshold: {{ .sensorValues.logs.pipeline.dropOldLogs.dropThreshold }} 
    oldLogDropAlwaysThreshold: {{ .sensorValues.logs.pipeline.dropOldLogs.dropAlwaysThreshold }}
    oldLogDelayStart: {{ .sensorValues.logs.pipeline.dropOldLogs.delayStart }} 
otelTracesAsLogs: true
otelPreprocess: true
tracesOtlpEndpoint:
  endpoint: {{ include "ingestion.traces.otlp.http.url" . }}
  insecureSkipVerify: {{ .Values.global.ingestion.tls_skip_verify }}
  writeTimeout: 10s
logsOtlpEndpoint:
  endpoint: {{ include "ingestion.logs.otlp.http.url" . }}
  insecureSkipVerify: {{ .Values.global.ingestion.tls_skip_verify }}
  writeTimeout: 10s
customOtlpEndpoint:
  endpoint: {{ include "ingestion.custom.otlp.http.url" . }}
  insecureSkipVerify: {{ .Values.global.ingestion.tls_skip_verify }}
  writeTimeout: 10s
  batchSize: 350
  flushInterval: 1s

{{ if $sensorValues.collectionEnabled }}
mySqlConfig:
  KeepSQLAlias: true
  ReplaceDigits: true
  CollectCommands: true

postgreSqlConfig:
  DBMS: "postgresql"
  KeepSQLAlias: true
  ReplaceDigits: true
  CollectCommands: true
{{ end }}

telemetry:
  enabled: {{ include "telemetry.enabled" . }}
  metrics:
    globalHosting:
      enabled: {{ not .Values.tags.incloud }}
      url: {{ include "sensor.telemetry.metrics.url" . }}
      interval: {{ include "telemetry.metrics.interval" . }}
    customerHosting:
      enabled: {{ .Values.global.telemetry.metrics.customerHosting.enabled }}
      url: {{ default (include "metrics-ingester.promethues-exposition.http.url" .) .Values.global.telemetry.metrics.customerHosting.url }}
      interval: {{ .Values.global.telemetry.metrics.customerHosting.interval }}

{{ if $sensorValues.collectionEnabled }}
k8sEntitiesWatch:
{{- $sensorValues.k8sEntitiesWatch | toYaml | nindent 6 }}
{{ end }}

{{ if $sensorValues.collectionEnabled }}
{{ if $sensorValues.sensitiveHeadersObfuscationConfig }}
sensitiveHeadersObfuscationConfig: 
  enabled: {{ coalesce $sensorValues.obfuscateData $sensorValues.sensitiveHeadersObfuscationConfig.enabled }}
  caseSensitive: false
  mode: {{ $sensorValues.sensitiveHeadersObfuscationConfig.mode }}
  specificKeys: {{ $sensorValues.sensitiveHeadersObfuscationConfig.specificKeys | toJson }}
{{ end }}
{{ end }}
{{- end -}}

{{- define "groundcover.sensor.service.ingestion-ports" -}}
{{- $sensorValues := .sensorValues -}}
{{- if $sensorValues.ingestionEnabled }}
{{- if and $sensorValues.apmIngestor.dataDog.enabled $sensorValues.apmIngestor.dataDog.tracesPort }}
- protocol: TCP
  name: dd-traces
  port: {{ $sensorValues.apmIngestor.dataDog.tracesPort }}
  targetPort: {{ $sensorValues.apmIngestor.dataDog.tracesPort }}
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.zipkin.enabled $sensorValues.apmIngestor.otel.direct.zipkin.port }}
- protocol: TCP
  name: zipkin
  port: {{ $sensorValues.apmIngestor.otel.direct.zipkin.port }}
  targetPort: {{ $sensorValues.apmIngestor.otel.direct.zipkin.port }}
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.otlp.enabled $sensorValues.apmIngestor.otel.direct.otlp.grpcPort }}
- protocol: TCP
  name: otlp-grpc
  port: {{ $sensorValues.apmIngestor.otel.direct.otlp.grpcPort }}
  targetPort: {{ $sensorValues.apmIngestor.otel.direct.grpcPort }}
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.otlp.enabled $sensorValues.apmIngestor.otel.direct.otlp.httpPort }}
- protocol: TCP
  name: otlp-http
  port: {{ $sensorValues.apmIngestor.otel.direct.otlp.httpPort }}
  targetPort: {{ $sensorValues.apmIngestor.otel.direct.httpPort }}
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.jaeger.enabled $sensorValues.apmIngestor.otel.direct.jaeger.grpcPort }}
- protocol: TCP
  name: jeager-grpc
  port: {{ $sensorValues.apmIngestor.otel.direct.jaeger.grpcPort }}
  targetPort: {{ $sensorValues.apmIngestor.otel.direct.jaeger.grpcPort }}
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.jaeger.enabled $sensorValues.apmIngestor.otel.direct.jaeger.thriftHttpPort }}
- protocol: TCP
  name: jeager-thrift-http
  port: {{ $sensorValues.apmIngestor.otel.direct.jaeger.thriftHttpPort }}
  targetPort: {{ $sensorValues.apmIngestor.otel.direct.jaeger.thriftHttpPort }}
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.jaeger.enabled $sensorValues.apmIngestor.otel.direct.jaeger.thriftBinaryPort }}
- protocol: UDP
  name: jeager-thrift-binary
  port: {{ $sensorValues.apmIngestor.otel.direct.jaeger.thriftBinaryPort }}
  targetPort: {{ $sensorValues.apmIngestor.otel.direct.jaeger.thriftBinaryPort }}
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.jaeger.enabled $sensorValues.apmIngestor.otel.direct.jaeger.thriftCompactPort }}
- protocol: UDP
  name: jeager-thrift-compact
  port: {{ $sensorValues.apmIngestor.otel.direct.jaeger.thriftCompactPort }}
  targetPort: {{ $sensorValues.apmIngestor.otel.direct.jaeger.thriftCompactPort }}
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.httpjson.enabled $sensorValues.apmIngestor.otel.direct.httpjson.port }}
- protocol: TCP
  name: http-json
  port: {{ $sensorValues.apmIngestor.otel.direct.httpjson.port }}
  targetPort: {{ $sensorValues.apmIngestor.otel.direct.httpjson.port }}
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.firehose.enabled $sensorValues.apmIngestor.otel.direct.firehose.port }}
- protocol: TCP
  name: firehose
  port: {{ $sensorValues.apmIngestor.otel.direct.firehose.port }}
  targetPort: {{ $sensorValues.apmIngestor.otel.direct.firehose.port }}
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.loki.enabled $sensorValues.apmIngestor.otel.direct.loki.port }}
- protocol: TCP
  name: loki
  port: {{ $sensorValues.apmIngestor.otel.direct.loki.port }}
  targetPort: {{ $sensorValues.apmIngestor.otel.direct.loki.port }}
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.rum.enabled $sensorValues.apmIngestor.otel.direct.rum.port }}
- protocol: TCP
  name: rum
  port: {{ $sensorValues.apmIngestor.otel.direct.rum.port }}
  targetPort: {{ $sensorValues.apmIngestor.otel.direct.rum.port }}
{{- end }}
{{- if and (eq "true" (include "groundcover.sensor.receivers.remotewrite.enabled" .)) (include "groundcover.sensor.receivers.remotewrite.port" .) }}
- protocol: TCP
  name: prometheus-remote-write
  port: {{ include "groundcover.sensor.receivers.remotewrite.port" . }}
  targetPort: {{ include "groundcover.sensor.receivers.remotewrite.port" . }}
{{- end }}
{{- if and $sensorValues.healthProbe.enabled $sensorValues.healthProbe.port }}
- protocol: TCP
  name: health-http
  port: {{ $sensorValues.healthProbe.port }}
  targetPort: {{ $sensorValues.healthProbe.port }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "groundcover.sensor.deployment.ingestion-ports" -}}
{{- $sensorValues := .sensorValues -}}
{{- if $sensorValues.ingestionEnabled }}
{{- if and $sensorValues.apmIngestor.dataDog.enabled $sensorValues.apmIngestor.dataDog.tracesPort }}
- containerPort: {{ $sensorValues.apmIngestor.dataDog.tracesPort }}
  name: dd-traces
  protocol: TCP
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.zipkin.enabled $sensorValues.apmIngestor.otel.direct.zipkin.port }}
- containerPort: {{ $sensorValues.apmIngestor.otel.direct.zipkin.port }}
  name: zipkin
  protocol: TCP
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.otlp.enabled $sensorValues.apmIngestor.otel.direct.otlp.grpcPort }}
- containerPort: {{ $sensorValues.apmIngestor.otel.direct.otlp.grpcPort }}
  name: otlp-grpc
  protocol: TCP
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.otlp.enabled $sensorValues.apmIngestor.otel.direct.otlp.httpPort }}
- containerPort: {{ $sensorValues.apmIngestor.otel.direct.otlp.httpPort }}
  name: otlp-http
  protocol: TCP
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.jaeger.enabled $sensorValues.apmIngestor.otel.direct.jaeger.grpcPort }}
- containerPort: {{ $sensorValues.apmIngestor.otel.direct.jaeger.grpcPort }}
  name: jaeger-grpc
  protocol: TCP     
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.jaeger.enabled $sensorValues.apmIngestor.otel.direct.jaeger.thriftHttpPort }}
- containerPort: {{ $sensorValues.apmIngestor.otel.direct.jaeger.thriftHttpPort }}
  name: jaeger-th-http
  protocol: TCP     
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.jaeger.enabled $sensorValues.apmIngestor.otel.direct.jaeger.thriftBinaryPort }}
- containerPort: {{ $sensorValues.apmIngestor.otel.direct.jaeger.thriftBinaryPort }}
  name: jaeger-th-bin
  protocol: UDP     
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.jaeger.enabled $sensorValues.apmIngestor.otel.direct.jaeger.thriftCompactPort }}
- containerPort: {{ $sensorValues.apmIngestor.otel.direct.jaeger.thriftCompactPort }}
  name: jaeger-th-comp
  protocol: UDP     
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.httpjson.enabled $sensorValues.apmIngestor.otel.direct.httpjson.port }}
- containerPort: {{ $sensorValues.apmIngestor.otel.direct.httpjson.port }}
  name: http-json
  protocol: TCP
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.firehose.enabled $sensorValues.apmIngestor.otel.direct.firehose.port }}
- containerPort: {{ $sensorValues.apmIngestor.otel.direct.firehose.port }}
  name: firehose
  protocol: TCP
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.loki.enabled $sensorValues.apmIngestor.otel.direct.loki.port }}
- containerPort: {{ $sensorValues.apmIngestor.otel.direct.loki.port }}
  name: loki-http
  protocol: TCP
{{- end }}
{{- if and $sensorValues.apmIngestor.otel.direct.rum.enabled $sensorValues.apmIngestor.otel.direct.rum.port }}
- containerPort: {{ $sensorValues.apmIngestor.otel.direct.rum.port }}
  name: rum
  protocol: TCP
{{- end }}
{{- if and (eq "true" (include "groundcover.sensor.receivers.remotewrite.enabled" .)) (include "groundcover.sensor.receivers.remotewrite.port" .) }}
- containerPort: {{ include "groundcover.sensor.receivers.remotewrite.port" . }}
  name: remote-write
  protocol: TCP     
{{- end }}
{{- if $sensorValues.healthProbe.enabled }}
- containerPort: {{ $sensorValues.healthProbe.port }}
  name: health-http
{{- end }}
{{- end }}
{{- end -}}

{{- define "groundcover.sensor.tracefs.mount.path" -}}
  {{- if .sensorValues.useOldTracefsMountPath -}}
    /sys/kernel/debug/tracing
  {{- else -}}
    /sys/kernel/tracing
  {{- end -}}
{{- end -}}