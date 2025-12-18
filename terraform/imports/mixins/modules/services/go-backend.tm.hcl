# Go Backend service module generation for stacks tagged with "go-backend"
# Generates main.tf with module call
#
# Required globals:
#   - global.namespace
#   - global.stage
#   - global.environment
#   - global.go_backend.kubernetes_namespace
#   - global.go_backend.kubernetes_service_account
#   - global.go_backend.force_destroy
#   - global.go_backend.bucket_versioning_enabled
#
# Required inputs (from outputs sharing):
#   - eks_cluster_name (from eks stack)

generate_hcl "main.tf" {
  condition = tm_contains(terramate.stack.tags, "go-backend")

  content {
    module "go_backend" {
      source = "${terramate.stack.path.to_root}/terraform/modules/services//go-backend"

      # CloudPosse context
      name        = "go-backend"
      namespace   = global.namespace
      stage       = global.stage
      environment = global.environment

      # From inputs (outputs sharing)
      eks_cluster_name = tm_hcl_expression("var.eks_cluster_name")

      # Stack-specific config from globals
      kubernetes_namespace       = global.go_backend.kubernetes_namespace
      kubernetes_service_account = global.go_backend.kubernetes_service_account
      force_destroy              = global.go_backend.force_destroy
      bucket_versioning_enabled  = global.go_backend.bucket_versioning_enabled
    }
  }
}
