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
#
# Module source configuration:
#   - When global.modules.use_pinned_versions is true: uses git source with pinned tag
#   - When false (default): uses local relative path for rapid iteration

generate_hcl "_main.tf" {
  condition = tm_contains(terramate.stack.tags, "go-backend")

  lets {
    # Determine module source based on configuration
    use_pinned    = tm_try(global.modules.use_pinned_versions, false)
    local_source  = "${terramate.stack.path.to_root}/terraform/modules/app-resources//go-backend"
    pinned_source = "${tm_try(global.modules.git_base_url, "")}//terraform/modules/app-resources/go-backend?ref=terraform/modules/app-resources/go-backend@${tm_try(global.modules.versions.app_resources_go_backend, "0.1.0")}"
    module_source = let.use_pinned ? let.pinned_source : let.local_source
  }

  content {
    module "go_backend" {
      source = let.module_source

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
