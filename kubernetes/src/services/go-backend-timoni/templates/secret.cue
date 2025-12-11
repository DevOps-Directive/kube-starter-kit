package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#DBSecret: corev1.#Secret & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Secret"
	metadata:   #config.metadata
	metadata: name: "go-backend-db-superuser"
	stringData: {
		username: "postgres"
		password: "password"
	}
}
