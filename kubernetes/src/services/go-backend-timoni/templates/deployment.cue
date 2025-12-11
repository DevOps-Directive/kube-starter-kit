package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#Deployment: appsv1.#Deployment & {
	#config:    #Config
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		name:      "go-backend"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
	}
	spec: appsv1.#DeploymentSpec & {
		replicas: #config.replicas
		selector: matchLabels: app: "go-backend"
		template: {
			metadata: {
				labels: app: "go-backend"
				if #config.podAnnotations != _|_ {
					annotations: #config.podAnnotations
				}
			}
			spec: corev1.#PodSpec & {
				serviceAccountName: #config.metadata.name
				containers: [
					{
						name:            "go-backend"
						image:           #config.image.reference
						imagePullPolicy: #config.image.pullPolicy
						env: [
							{
								name: "DATABASE_URL"
								valueFrom: secretKeyRef: {
									name: "go-backend-pg-app"
									key:  "uri"
								}
							},
							{
								name:  "OTEL_EXPORTER_OTLP_ENDPOINT"
								value: #config.otel.endpoint
							},
							{
								name:  "OTEL_SERVICE_NAME"
								value: #config.otel.serviceName
							},
						]
						resources:       #config.resources
						securityContext: #config.securityContext
					},
				]
				if #config.podSecurityContext != _|_ {
					securityContext: #config.podSecurityContext
				}
				if #config.topologySpreadConstraints != _|_ {
					topologySpreadConstraints: #config.topologySpreadConstraints
				}
				if #config.affinity != _|_ {
					affinity: #config.affinity
				}
				if #config.tolerations != _|_ {
					tolerations: #config.tolerations
				}
				if #config.imagePullSecrets != _|_ {
					imagePullSecrets: #config.imagePullSecrets
				}
			}
		}
	}
}
