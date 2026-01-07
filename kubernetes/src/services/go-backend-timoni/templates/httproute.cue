package templates

// HTTPRoute using the shared Traefik Gateway
// Requires:
//   - Gateway API CRDs installed (kubernetes/src/infrastructure/gateway-api-crds/)
//   - Traefik with Gateway API support enabled
//   - ReferenceGrant in traefik namespace allowing cross-namespace references
#HTTPRouteTraefik: {
	#config:    #Config
	apiVersion: "gateway.networking.k8s.io/v1"
	kind:       "HTTPRoute"
	metadata: {
		name:      "traefik"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
		annotations: {
			"external-dns.alpha.kubernetes.io/hostname": #config.gateway.traefik.hostname
		}
	}
	spec: {
		hostnames: [#config.gateway.traefik.hostname]
		parentRefs: [{
			name:      "traefik-gateway"
			namespace: "traefik"
		}]
		rules: [{
			backendRefs: [{
				name: "go-backend"
				port: #config.service.port
			}]
			matches: [{
				path: {
					type:  "PathPrefix"
					value: "/"
				}
			}]
		}]
	}
}
