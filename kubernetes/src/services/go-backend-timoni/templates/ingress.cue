package templates

import (
	networkingv1 "k8s.io/api/networking/v1"
)

#IngressNginx: networkingv1.#Ingress & {
	#config:    #Config
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata: {
		name:      "minimal-nginx"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
		annotations: {
			"external-dns.alpha.kubernetes.io/hostname": #config.ingress.nginx.hostname
		}
	}
	spec: networkingv1.#IngressSpec & {
		ingressClassName: "nginx"
		rules: [{
			host: #config.ingress.nginx.hostname
			http: paths: [{
				path:     "/"
				pathType: "Prefix"
				backend: service: {
					name: "go-backend"
					port: number: #config.service.port
				}
			}]
		}]
	}
}

#IngressTraefik: networkingv1.#Ingress & {
	#config:    #Config
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata: {
		name:      "minimal-traefik"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
		annotations: {
			"external-dns.alpha.kubernetes.io/hostname": #config.ingress.traefik.hostname
		}
	}
	spec: networkingv1.#IngressSpec & {
		ingressClassName: "traefik"
		rules: [{
			host: #config.ingress.traefik.hostname
			http: paths: [{
				path:     "/"
				pathType: "Prefix"
				backend: service: {
					name: "go-backend"
					port: number: #config.service.port
				}
			}]
		}]
	}
}

#IngressIstio: networkingv1.#Ingress & {
	#config:    #Config
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata: {
		name:      "minimal-istio"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
		annotations: {
			"external-dns.alpha.kubernetes.io/hostname": #config.ingress.istio.hostname
		}
	}
	spec: networkingv1.#IngressSpec & {
		ingressClassName: "istio"
		rules: [{
			host: #config.ingress.istio.hostname
			http: paths: [{
				path:     "/"
				pathType: "ImplementationSpecific"
				backend: service: {
					name: "go-backend"
					port: number: #config.service.port
				}
			}]
		}]
	}
}
