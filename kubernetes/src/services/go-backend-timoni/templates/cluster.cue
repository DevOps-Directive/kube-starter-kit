package templates

#CNPGCluster: {
	#config:    #Config
	apiVersion: "postgresql.cnpg.io/v1"
	kind:       "Cluster"
	metadata: {
		name:      "go-backend-pg"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
	}
	spec: {
		instances: #config.db.instances
		storage: {
			size:         #config.db.storageSize
			storageClass: #config.db.storageClass
		}
		superuserSecret: name: "go-backend-db-superuser"
		imageName: #config.db.image
	}
}
