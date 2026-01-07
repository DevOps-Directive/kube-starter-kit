package templates

import (
	networkingv1 "k8s.io/api/networking/v1"
	"strings"
)

// Helper to generate TLS secret name from hostname if not provided
#tlsSecretName: {
	#hostname:  string
	#provided:  string
	out: string
	if #provided != "" {
		out: #provided
	}
	if #provided == "" {
		out: strings.Replace(#hostname, ".", "-", -1) + "-tls"
	}
}

#IngressTraefik: networkingv1.#Ingress & {
	#config:    #Config
	#_tlsSecret: (#tlsSecretName & {#hostname: #config.ingress.traefik.hostname, #provided: #config.ingress.traefik.tlsSecretName}).out
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata: {
		name:      "minimal-traefik"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
		annotations: {
			"external-dns.alpha.kubernetes.io/hostname": #config.ingress.traefik.hostname
			"cert-manager.io/cluster-issuer":            #config.ingress.traefik.clusterIssuer
		}
	}
	spec: networkingv1.#IngressSpec & {
		ingressClassName: "traefik"
		tls: [{
			hosts: [#config.ingress.traefik.hostname]
			secretName: #_tlsSecret
		}]
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
	#_tlsSecret: (#tlsSecretName & {#hostname: #config.ingress.istio.hostname, #provided: #config.ingress.istio.tlsSecretName}).out
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata: {
		name:      "minimal-istio"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
		annotations: {
			"external-dns.alpha.kubernetes.io/hostname": #config.ingress.istio.hostname
			"cert-manager.io/cluster-issuer":            #config.ingress.istio.clusterIssuer
		}
	}
	spec: networkingv1.#IngressSpec & {
		ingressClassName: "istio"
		tls: [{
			hosts: [#config.ingress.istio.hostname]
			secretName: #_tlsSecret
		}]
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
