# keep

![Version: 0.1.66](https://img.shields.io/badge/Version-0.1.66-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.37.10](https://img.shields.io/badge/AppVersion-0.37.10-informational?style=flat-square)

Keep Helm Chart

**Homepage:** <https://platform.keephq.dev/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Shahar Glazner | <shahar@keephq.dev> | <https://github.com/shahargl> |
| Tal Borenstein | <tal@keephq.dev> | <https://github.com/talboren> |

## Source Code

* <https://github.com/keephq/helm-charts>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalLabels | object | `{}` |  |
| backend.affinity | object | `{}` |  |
| backend.autoscaling.enabled | bool | `false` |  |
| backend.autoscaling.maxReplicas | int | `3` |  |
| backend.autoscaling.minReplicas | int | `1` |  |
| backend.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| backend.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| backend.backendConfig.healthCheck.checkIntervalSec | int | `30` |  |
| backend.backendConfig.healthCheck.healthyThreshold | int | `1` |  |
| backend.backendConfig.healthCheck.path | string | `"/docs"` |  |
| backend.backendConfig.healthCheck.port | int | `8080` |  |
| backend.backendConfig.healthCheck.timeoutSec | int | `10` |  |
| backend.backendConfig.healthCheck.type | string | `"HTTP"` |  |
| backend.backendConfig.healthCheck.unhealthyThreshold | int | `3` |  |
| backend.databaseConnectionStringFromSecret.enabled | bool | `false` |  |
| backend.databaseConnectionStringFromSecret.secretKey | string | `""` |  |
| backend.databaseConnectionStringFromSecret.secretName | string | `""` |  |
| backend.enabled | bool | `true` |  |
| backend.envFromConfigMaps | list | `[]` | configmaps to include. Must include name and can be marked as optional. each entry should contain a name key, and can optionally specify whether the configmap must be defined with an optional key. |
| backend.envFromSecret | string | `""` | Name of the secret to include |
| backend.envFromSecrets | list | `[]` | List of secrets to include. Must include name and can be marked as optional. |
| backend.envRenderSecret | object | `{}` | Sensible environment variables will be rendered as a new secret object; escape {{ in secret values to avoid Helm interpretation. |
| backend.env[0].name | string | `"DATABASE_CONNECTION_STRING"` |  |
| backend.env[0].value | string | `"mysql+pymysql://root@keep-database:3306/keep"` |  |
| backend.env[1].name | string | `"DATABASE_NAME"` |  |
| backend.env[1].value | string | `"keep-database"` |  |
| backend.env[2].name | string | `"SECRET_MANAGER_TYPE"` |  |
| backend.env[2].value | string | `"k8s"` |  |
| backend.env[3].name | string | `"PORT"` |  |
| backend.env[3].value | string | `"8080"` |  |
| backend.env[4].name | string | `"PUSHER_APP_ID"` |  |
| backend.env[4].value | int | `1` |  |
| backend.env[5].name | string | `"PUSHER_APP_KEY"` |  |
| backend.env[5].value | string | `"keepappkey"` |  |
| backend.env[6].name | string | `"PUSHER_APP_SECRET"` |  |
| backend.env[6].value | string | `"keepappsecret"` |  |
| backend.env[7].name | string | `"PUSHER_HOST"` |  |
| backend.env[7].value | string | `"keep-websocket"` |  |
| backend.env[8].name | string | `"PUSHER_PORT"` |  |
| backend.env[8].value | int | `6001` |  |
| backend.env[9].name | string | `"PROMETHEUS_MULTIPROC_DIR"` |  |
| backend.env[9].value | string | `"/tmp/prometheus"` |  |
| backend.extraInitContainers | list | `[]` |  |
| backend.extraVolumeMounts | list | `[]` |  |
| backend.extraVolumes | list | `[]` |  |
| backend.healthCheck.enabled | bool | `false` |  |
| backend.healthCheck.probes.livenessProbe.tcpSocket.port | int | `8080` |  |
| backend.healthCheck.probes.readinessProbe.initialDelaySeconds | int | `30` |  |
| backend.healthCheck.probes.readinessProbe.periodSeconds | int | `10` |  |
| backend.healthCheck.probes.readinessProbe.tcpSocket.port | int | `8080` |  |
| backend.image.pullPolicy | string | `"Always"` |  |
| backend.image.repository | string | `"us-central1-docker.pkg.dev/keephq/keep/keep-api"` |  |
| backend.imagePullSecrets | list | `[]` |  |
| backend.nodeSelector | object | `{}` |  |
| backend.openAiApi.enabled | bool | `false` |  |
| backend.openAiApi.openAiApiKey | string | `""` |  |
| backend.podAnnotations."prometheus.io/path" | string | `"/metrics/processing"` |  |
| backend.podAnnotations."prometheus.io/port" | string | `"8080"` |  |
| backend.podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| backend.podSecurityContext | object | `{}` |  |
| backend.replicaCount | int | `1` |  |
| backend.resources | object | `{}` |  |
| backend.route.enabled | bool | `false` |  |
| backend.route.host | string | `"chart-example-backend.local"` |  |
| backend.route.path | string | `"/"` |  |
| backend.route.tls | list | `[]` |  |
| backend.route.wildcardPolicy | string | `"None"` |  |
| backend.securityContext | object | `{}` |  |
| backend.service.port | int | `8080` |  |
| backend.service.type | string | `"ClusterIP"` |  |
| backend.tolerations | list | `[]` |  |
| backend.topologySpreadConstraints | list | `[]` |  |
| backend.waitForDatabase.enabled | bool | `true` |  |
| backend.waitForDatabase.port | int | `3306` |  |
| database.affinity | object | `{}` |  |
| database.autoscaling.enabled | bool | `false` |  |
| database.enabled | bool | `true` |  |
| database.env[0].name | string | `"MYSQL_ALLOW_EMPTY_PASSWORD"` |  |
| database.env[0].value | bool | `true` |  |
| database.env[1].name | string | `"MYSQL_DATABASE"` |  |
| database.env[1].value | string | `"keep"` |  |
| database.env[2].name | string | `"MYSQL_PASSWORD"` |  |
| database.env[2].value | string | `nil` |  |
| database.extraVolumeMounts | list | `[]` |  |
| database.extraVolumes | list | `[]` |  |
| database.healthCheck.enabled | bool | `false` |  |
| database.healthCheck.probes.livenessProbe.tcpSocket.port | int | `3306` |  |
| database.healthCheck.probes.readinessProbe.initialDelaySeconds | int | `30` |  |
| database.healthCheck.probes.readinessProbe.periodSeconds | int | `10` |  |
| database.healthCheck.probes.readinessProbe.tcpSocket.port | int | `3306` |  |
| database.image.pullPolicy | string | `"IfNotPresent"` |  |
| database.image.repository | string | `"mysql"` |  |
| database.image.tag | string | `"latest"` |  |
| database.imagePullSecrets | list | `[]` |  |
| database.nodeSelector | object | `{}` |  |
| database.podAnnotations | object | `{}` |  |
| database.podSecurityContext | object | `{}` |  |
| database.pv.enabled | bool | `true` |  |
| database.pv.size | string | `"5Gi"` |  |
| database.pv.storageClass | string | `""` |  |
| database.pvc.enabled | bool | `true` |  |
| database.pvc.retain | bool | `false` |  |
| database.pvc.size | string | `"5Gi"` |  |
| database.pvc.storageClass | string | `""` |  |
| database.replicaCount | int | `1` |  |
| database.resources | object | `{}` |  |
| database.securityContext | object | `{}` |  |
| database.service.port | int | `3306` |  |
| database.service.type | string | `"ClusterIP"` |  |
| database.strategy.rollingUpdate.maxSurge | int | `0` |  |
| database.strategy.rollingUpdate.maxUnavailable | int | `1` |  |
| database.strategy.type | string | `"RollingUpdate"` |  |
| database.tolerations | list | `[]` |  |
| deleteSecretJob.image.pullPolicy | string | `"Always"` |  |
| deleteSecretJob.image.repository | string | `"bitnami/kubectl"` |  |
| deleteSecretJob.image.tag | string | `"latest"` |  |
| frontend.affinity | object | `{}` |  |
| frontend.autoscaling.enabled | bool | `false` |  |
| frontend.autoscaling.maxReplicas | int | `3` |  |
| frontend.autoscaling.minReplicas | int | `1` |  |
| frontend.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| frontend.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| frontend.backendConfig.healthCheck.checkIntervalSec | int | `30` |  |
| frontend.backendConfig.healthCheck.healthyThreshold | int | `1` |  |
| frontend.backendConfig.healthCheck.path | string | `"/signin"` |  |
| frontend.backendConfig.healthCheck.port | int | `3000` |  |
| frontend.backendConfig.healthCheck.timeoutSec | int | `10` |  |
| frontend.backendConfig.healthCheck.type | string | `"HTTP"` |  |
| frontend.backendConfig.healthCheck.unhealthyThreshold | int | `3` |  |
| frontend.enabled | bool | `true` |  |
| frontend.envFromConfigMaps | list | `[]` | Configmaps to include. Must include name and can be marked as optional. each entry should contain a name key, and can optionally specify whether the configmap must be defined with an optional key. |
| frontend.envFromSecret | string | `""` | Name of the secret to include |
| frontend.envFromSecrets | list | `[]` | List of secrets to include. Must include name and can be marked as optional. |
| frontend.envRenderSecret | object | `{}` | Sensible environment variables will be rendered as a new secret object; escape {{ in secret values to avoid Helm interpretation. |
| frontend.env[0].name | string | `"NEXTAUTH_SECRET"` |  |
| frontend.env[0].value | string | `"secret"` |  |
| frontend.env[1].name | string | `"VERCEL"` |  |
| frontend.env[1].value | int | `1` |  |
| frontend.env[2].name | string | `"ENV"` |  |
| frontend.env[2].value | string | `"development"` |  |
| frontend.env[3].name | string | `"NODE_ENV"` |  |
| frontend.env[3].value | string | `"development"` |  |
| frontend.env[4].name | string | `"HOSTNAME"` |  |
| frontend.env[4].value | string | `"0.0.0.0"` |  |
| frontend.env[5].name | string | `"PUSHER_APP_KEY"` |  |
| frontend.env[5].value | string | `"keepappkey"` |  |
| frontend.healthCheck.enabled | bool | `false` |  |
| frontend.healthCheck.probes.livenessProbe.httpGet.path | string | `"/"` |  |
| frontend.healthCheck.probes.livenessProbe.httpGet.port | string | `"http"` |  |
| frontend.healthCheck.probes.readinessProbe.httpGet.path | string | `"/"` |  |
| frontend.healthCheck.probes.readinessProbe.httpGet.port | string | `"http"` |  |
| frontend.image.pullPolicy | string | `"Always"` |  |
| frontend.image.repository | string | `"us-central1-docker.pkg.dev/keephq/keep/keep-ui"` |  |
| frontend.imagePullSecrets | list | `[]` |  |
| frontend.nodeSelector | object | `{}` |  |
| frontend.podAnnotations | object | `{}` |  |
| frontend.podSecurityContext | object | `{}` |  |
| frontend.replicaCount | int | `1` |  |
| frontend.resources | object | `{}` |  |
| frontend.route.enabled | bool | `false` |  |
| frontend.route.host | string | `"chart-example.local"` |  |
| frontend.route.path | string | `"/"` |  |
| frontend.route.tls | list | `[]` |  |
| frontend.route.wildcardPolicy | string | `"None"` |  |
| frontend.securityContext | object | `{}` |  |
| frontend.service.port | int | `3000` |  |
| frontend.service.type | string | `"ClusterIP"` |  |
| frontend.serviceAccount.annotations | object | `{}` |  |
| frontend.serviceAccount.create | bool | `true` |  |
| frontend.serviceAccount.name | string | `""` |  |
| frontend.tolerations | list | `[]` |  |
| frontend.topologySpreadConstraints | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| global.ingress.annotations | object | `{}` |  |
| global.ingress.backendPrefix | string | `"/v2"` |  |
| global.ingress.className | string | `"nginx"` |  |
| global.ingress.classType | string | `""` |  |
| global.ingress.enabled | bool | `true` |  |
| global.ingress.frontendPrefix | string | `"/"` |  |
| global.ingress.hosts | list | `[]` |  |
| global.ingress.tls | list | `[]` |  |
| global.ingress.websocketPrefix | string | `"/websocket"` |  |
| isGKE | bool | `false` |  |
| nameOverride | string | `""` |  |
| namespace | string | `"keep"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| websocket.affinity | object | `{}` |  |
| websocket.autoscaling.enabled | bool | `false` |  |
| websocket.autoscaling.maxReplicas | int | `3` |  |
| websocket.autoscaling.minReplicas | int | `1` |  |
| websocket.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| websocket.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| websocket.enabled | bool | `true` |  |
| websocket.env[0].name | string | `"SOKETI_HOST"` |  |
| websocket.env[0].value | string | `"0.0.0.0"` |  |
| websocket.env[1].name | string | `"SOKETI_DEBUG"` |  |
| websocket.env[1].value | string | `"1"` |  |
| websocket.env[2].name | string | `"SOKETI_USER_AUTHENTICATION_TIMEOUT"` |  |
| websocket.env[2].value | int | `3000` |  |
| websocket.env[3].name | string | `"SOKETI_DEFAULT_APP_ID"` |  |
| websocket.env[3].value | int | `1` |  |
| websocket.env[4].name | string | `"SOKETI_DEFAULT_APP_KEY"` |  |
| websocket.env[4].value | string | `"keepappkey"` |  |
| websocket.env[5].name | string | `"SOKETI_DEFAULT_APP_SECRET"` |  |
| websocket.env[5].value | string | `"keepappsecret"` |  |
| websocket.healthCheck.enabled | bool | `false` |  |
| websocket.healthCheck.probes.livenessProbe.httpGet.path | string | `"/"` |  |
| websocket.healthCheck.probes.livenessProbe.httpGet.port | string | `"http"` |  |
| websocket.healthCheck.probes.readinessProbe.httpGet.path | string | `"/"` |  |
| websocket.healthCheck.probes.readinessProbe.httpGet.port | string | `"http"` |  |
| websocket.image.pullPolicy | string | `"Always"` |  |
| websocket.image.repository | string | `"quay.io/soketi/soketi"` |  |
| websocket.image.tag | string | `"1.4-16-debian"` |  |
| websocket.imagePullSecrets | list | `[]` |  |
| websocket.nodeSelector | object | `{}` |  |
| websocket.podAnnotations | object | `{}` |  |
| websocket.podSecurityContext | object | `{}` |  |
| websocket.replicaCount | int | `1` |  |
| websocket.resources | object | `{}` |  |
| websocket.route.enabled | bool | `false` |  |
| websocket.route.host | string | `"chart-example.local"` |  |
| websocket.route.tls | list | `[]` |  |
| websocket.route.wildcardPolicy | string | `"None"` |  |
| websocket.securityContext | object | `{}` |  |
| websocket.service.port | int | `6001` |  |
| websocket.service.type | string | `"ClusterIP"` |  |
| websocket.serviceAccount.annotations | object | `{}` |  |
| websocket.serviceAccount.create | bool | `true` |  |
| websocket.serviceAccount.name | string | `""` |  |
| websocket.tolerations | list | `[]` |  |
| websocket.topologySpreadConstraints | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
