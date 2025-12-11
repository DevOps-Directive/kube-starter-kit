package templates

import (
	batchv1 "k8s.io/api/batch/v1"
	corev1 "k8s.io/api/core/v1"
)

#MigrationJob: batchv1.#Job & {
	#config:    #Config
	apiVersion: "batch/v1"
	kind:       "Job"
	metadata:   #config.metadata
	metadata: name: "go-backend-migrate"
	metadata: annotations: {
		"kluctl.io/hook": "pre-deploy"
	}
	spec: batchv1.#JobSpec & {
		ttlSecondsAfterFinished: 3600
		template: corev1.#PodTemplateSpec & {
			spec: {
				restartPolicy: "Never"
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
				}]
			}
		}
	}
}
