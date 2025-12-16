package templates

import (
	batchv1 "k8s.io/api/batch/v1"
	corev1 "k8s.io/api/core/v1"
)

#MigrationJob: batchv1.#Job & {
	#config:    #Config
	apiVersion: "batch/v1"
	kind:       "Job"
	metadata: {
		name:      "go-backend-migrate"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
		annotations: {
			"kluctl.io/hook": "pre-deploy"
		}
	}
	spec: batchv1.#JobSpec & {
		ttlSecondsAfterFinished: 3600
		template: corev1.#PodTemplateSpec & {
			spec: {
				restartPolicy: "Never"
				securityContext: {
					runAsNonRoot: true
					runAsUser:    1001
					runAsGroup:   1001
					fsGroup:      1001
					seccompProfile: type: "RuntimeDefault"
				}
				containers: [{
					name:  "apply"
					image: #config.migration.image
					args: [
						"migrate",
						"apply",
						"--dir",
						"file://migrations",
						"--url",
						"$(DATABASE_URL)",
					]
					env: [{
						name: "DATABASE_URL"
						valueFrom: secretKeyRef: {
							name: "go-backend-pg-app"
							key:  "uri"
						}
					}]
					resources: {
						requests: {
							cpu:    "50m"
							memory: "64Mi"
						}
						limits: memory: "128Mi"
					}
					securityContext: {
						allowPrivilegeEscalation: false
						privileged:               false
						readOnlyRootFilesystem:   true
						capabilities: drop: ["ALL"]
					}
				}]
			}
		}
	}
}
