package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#Service: corev1.#Service & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata:   #config.metadata
	metadata: name: "go-backend"
	if #config.service.annotations != _|_ {
		metadata: annotations: #config.service.annotations
	}
	spec: corev1.#ServiceSpec & {
		type:     corev1.#ServiceTypeClusterIP
		selector: app: "go-backend"
		ports: [
			{
				port:       #config.service.port
				protocol:   "TCP"
				name:       "http"
				targetPort: #config.service.port
			},
		]
	}
}
