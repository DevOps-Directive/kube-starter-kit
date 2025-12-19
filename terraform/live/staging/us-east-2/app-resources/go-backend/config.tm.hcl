# Stack-specific configuration
globals "go_backend" {
  kubernetes_namespace       = "go-backend-kustomize"
  kubernetes_service_account = "go-backend"
  force_destroy              = true # Set to false for production
  bucket_versioning_enabled  = true
}
