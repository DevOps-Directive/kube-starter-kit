# Go Backend service module generation for stacks tagged with "go-backend"
# Generates main.tf with module call and _outputs.tm.hcl for outputs sharing
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

generate_hcl "_main.tf" {
  condition = tm_contains(terramate.stack.tags, "go-backend")

  content {
    module "go_backend" {
      source = "${terramate.stack.path.to_root}/terraform/modules/app-resources//go-backend"

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

# Generate informational outputs (not shared with other stacks)
generate_hcl "_outputs_info.tf" {
  condition = tm_contains(terramate.stack.tags, "go-backend")

  content {
    output "s3_bucket_id" {
      value = tm_hcl_expression("module.go_backend.s3_bucket_id")
    }

    output "s3_bucket_arn" {
      value = tm_hcl_expression("module.go_backend.s3_bucket_arn")
    }

    output "s3_bucket_regional_domain_name" {
      value = tm_hcl_expression("module.go_backend.s3_bucket_regional_domain_name")
    }

    output "iam_policy_arn" {
      value = tm_hcl_expression("module.go_backend.iam_policy_arn")
    }

    output "iam_role_arn" {
      value = tm_hcl_expression("module.go_backend.iam_role_arn")
    }

    output "iam_role_name" {
      value = tm_hcl_expression("module.go_backend.iam_role_name")
    }

    output "pod_identity_association_id" {
      value = tm_hcl_expression("module.go_backend.pod_identity_association_id")
    }
  }
}
