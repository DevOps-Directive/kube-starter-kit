package templates

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// The kubeVersion is a required field, set at apply-time
	// via timoni.cue by querying the user's Kubernetes API.
	kubeVersion!: string
	// Using the kubeVersion you can enforce a minimum Kubernetes minor version.
	// By default, the minimum Kubernetes version is set to 1.20.
	clusterVersion: timoniv1.#SemVer & {#Version: kubeVersion, #Minimum: "1.20.0"}

	// The moduleVersion is set from the user-supplied module version.
	// This field is used for the `app.kubernetes.io/version` label.
	moduleVersion!: string

	// The Kubernetes metadata common to all resources.
	// The `metadata.name` and `metadata.namespace` fields are
	// set from the user-supplied instance name and namespace.
	metadata: timoniv1.#Metadata & {#Version: moduleVersion}

	// The labels allows adding `metadata.labels` to all resources.
	// The `app.kubernetes.io/name` and `app.kubernetes.io/version` labels
	// are automatically generated and can't be overwritten.
	metadata: labels: timoniv1.#Labels

	// The annotations allows adding `metadata.annotations` to all resources.
	metadata: annotations?: timoniv1.#Annotations

	// The selector allows adding label selectors to Deployments and Services.
	// The `app.kubernetes.io/name` label selector is automatically generated
	// from the instance name and can't be overwritten.
	selector: timoniv1.#Selector & {#Name: metadata.name}

	// The image allows setting the container image repository,
	// tag, digest and pull policy.
	image!: timoniv1.#Image

	// The resources allows setting the container resource requirements.
	// By default, the container requests 100m CPU and 128Mi memory with a 256Mi limit.
	resources: timoniv1.#ResourceRequirements & {
		requests: {
			cpu:    *"100m" | timoniv1.#CPUQuantity
			memory: *"128Mi" | timoniv1.#MemoryQuantity
		}
		limits: {
			memory: *"256Mi" | timoniv1.#MemoryQuantity
		}
	}

	// The number of pods replicas.
	// By default, the number of replicas is 1.
	replicas: *1 | int & >0

	// The securityContext allows setting the container security context.
	// By default, the container is denied privilege escalation and uses read-only root filesystem.
	securityContext: corev1.#SecurityContext & {
		allowPrivilegeEscalation: *false | true
		privileged:               *false | true
		readOnlyRootFilesystem:   *true | false
		capabilities: {
			drop: *["ALL"] | [...string]
		}
	}

	// The probes configure health check endpoints for the container.
	probes: {
		readiness: corev1.#Probe & {
			httpGet: {
				path: *"/healthz" | string
				port: *8080 | int
			}
			initialDelaySeconds: *5 | int
			periodSeconds:       *10 | int
			timeoutSeconds:      *5 | int
			failureThreshold:    *3 | int
		}
		liveness: corev1.#Probe & {
			httpGet: {
				path: *"/livez" | string
				port: *8080 | int
			}
			initialDelaySeconds: *10 | int
			periodSeconds:       *15 | int
			timeoutSeconds:      *5 | int
			failureThreshold:    *3 | int
		}
	}

	// terminationGracePeriodSeconds allows configuring the pod termination grace period.
	terminationGracePeriodSeconds: *30 | int & >0

	// The service allows setting the Kubernetes Service annotations and port.
	// By default, the HTTP port is 8080.
	service: {
		annotations?: timoniv1.#Annotations
		port: *8080 | int & >0 & <=65535
	}

	// Pod optional settings.
	podAnnotations?: {[string]: string}
	imagePullSecrets?: [...timoniv1.#ObjectReference]
	tolerations?: [...corev1.#Toleration]
	affinity?: corev1.#Affinity
	topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]

	// The podSecurityContext configures pod-level security settings.
	// By default, the pod runs as non-root with seccomp enabled.
	podSecurityContext: corev1.#PodSecurityContext & {
		runAsNonRoot: *true | false
		runAsUser:    *1001 | int
		runAsGroup:   *1001 | int
		fsGroup:      *1001 | int
		seccompProfile: {
			type: *"RuntimeDefault" | string
		}
	}

	// Database configuration for CNPG PostgreSQL.
	db: {
		image!:        string
		storageClass!: string
		storageSize:   *"1Gi" | string
		instances:     *1 | int & >0
	}

	// Migration job configuration.
	migration: {
		image!: string
	}

	// OTEL telemetry configuration.
	otel: {
		endpoint:    *"signoz-k8s-infra-otel-agent.signoz:4317" | string
		serviceName: *"go-backend-timoni" | string
	}

	// Ingress configuration.
	ingress: {
		enabled: *true | bool
		nginx: {
			enabled:  *true | bool
			hostname: *"ingress-nginx-timoni.staging.kubestarterkit.com" | string
		}
		traefik: {
			enabled:  *true | bool
			hostname: *"ingress-traefik-timoni.staging.kubestarterkit.com" | string
		}
		istio: {
			enabled:  *false | bool
			hostname: *"minimal-istio-timoni.staging.kubestarterkit.com" | string
		}
	}

	// Test Job disabled by default.
	test: {
		enabled: *false | bool
		image!:  timoniv1.#Image
	}
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		ns: #Namespace & {#config: config}
		sa: #ServiceAccount & {#config: config}
		svc: #Service & {#config: config}
		secret: #DBSecret & {#config: config}
		cluster: #CNPGCluster & {#config: config}
		migrationJob: #MigrationJob & {#config: config}
		deploy: #Deployment & {#config: config}
		if config.ingress.enabled && config.ingress.nginx.enabled {
			ingressNginx: #IngressNginx & {#config: config}
		}
		if config.ingress.enabled && config.ingress.traefik.enabled {
			ingressTraefik: #IngressTraefik & {#config: config}
		}
		if config.ingress.enabled && config.ingress.istio.enabled {
			ingressIstio: #IngressIstio & {#config: config}
		}
	}

	tests: {
		"test-svc": #TestJob & {#config: config}
	}
}
