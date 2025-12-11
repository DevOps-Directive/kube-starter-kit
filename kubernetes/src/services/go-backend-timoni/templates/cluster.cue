package templates

#CNPGCluster: {
	#config:    #Config
	apiVersion: "postgresql.cnpg.io/v1"
	kind:       "Cluster"
	metadata:   #config.metadata
	metadata: name: "go-backend-pg"
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
