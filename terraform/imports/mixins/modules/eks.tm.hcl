# EKS module generation for stacks tagged with "eks"
# Generates main.tf with module call and _outputs.tm.hcl for outputs sharing
#
# Required globals:
#   - global.namespace
#   - global.stage  
#   - global.environment
#   - global.aws_region
#   - global.terraform_iam_role_arn
#   - global.admin_sso_role_arn
#   - global.eks.kubernetes_version
#   - global.eks.base_node_group_kubernetes_version
#   - global.eks.endpoint_public_access
#   - global.eks.endpoint_private_access
#   - global.eks.argocd_hostname
#
# Optional globals:
#   - global.eks.base_node_group_ami_release_version (defaults to null - uses latest)
#   - global.eks.eks_addon_versions (defaults to null - uses module defaults)
#
# Required inputs (from outputs sharing):
#   - vpc_id (from networking stack)
#   - vpc_cidr (from networking stack)
#   - private_subnets (from networking stack)
#   - route53_zone_arn (from bootstrapping stack)
#
# Module source configuration:
#   - When global.modules.use_pinned_versions is true: uses git source with pinned tag
#   - When false (default): uses local relative path for rapid iteration

generate_hcl "_main.tf" {
  condition = tm_contains(terramate.stack.tags, "eks")

  lets {
    # Determine module source based on configuration
    use_pinned    = tm_try(global.modules.use_pinned_versions, false)
    local_source  = "${terramate.stack.path.to_root}/terraform/modules//eks"
    pinned_source = "${tm_try(global.modules.git_base_url, "")}//terraform/modules/eks?ref=terraform/modules/eks@${tm_try(global.modules.versions.eks, "0.1.0")}"
    module_source = let.use_pinned ? let.pinned_source : let.local_source
  }

  content {
    module "eks" {
      source = let.module_source

      # CloudPosse context
      name        = "eks"
      namespace   = global.namespace
      stage       = global.stage
      environment = global.environment

      # From globals
      aws_region             = global.aws_region
      terraform_iam_role_arn = global.terraform_iam_role_arn
      admin_sso_role_arn     = global.admin_sso_role_arn

      # From inputs (outputs sharing) - these become variables
      vpc_id           = tm_hcl_expression("var.vpc_id")
      vpc_cidr         = tm_hcl_expression("var.vpc_cidr")
      private_subnets  = tm_hcl_expression("var.private_subnets")
      route53_zone_arn = tm_hcl_expression("var.route53_zone_arn")

      # Stack-specific config from globals
      kubernetes_version                  = global.eks.kubernetes_version
      base_node_group_kubernetes_version  = global.eks.base_node_group_kubernetes_version
      base_node_group_ami_release_version = tm_try(global.eks.base_node_group_ami_release_version, null)
      endpoint_public_access              = global.eks.endpoint_public_access
      endpoint_private_access             = global.eks.endpoint_private_access
      argocd_hostname                     = global.eks.argocd_hostname
      eks_addon_versions                  = tm_try(global.eks.eks_addon_versions, null)
    }
  }
}

# Generate outputs for sharing with dependent stacks
# Note: Requires running `terramate generate` twice - first creates this file,
# second run parses it and updates _sharing.tf
generate_hcl "_outputs.tm.hcl" {
  condition = tm_contains(terramate.stack.tags, "eks")

  content {
    output "eks_cluster_name" {
      backend = "terraform"
      value   = tm_hcl_expression("module.eks.eks_cluster_name")
    }
  }
}

# Generate informational outputs (not shared with other stacks)
generate_hcl "_outputs_info.tf" {
  condition = tm_contains(terramate.stack.tags, "eks")

  content {
    output "eks_cluster_endpoint" {
      value = tm_hcl_expression("module.eks.eks_cluster_endpoint")
    }

    output "karpenter_interruption_queue" {
      value = tm_hcl_expression("module.eks.karpenter_interruption_queue")
    }

    output "karpenter_node_role_name" {
      value = tm_hcl_expression("module.eks.karpenter_node_role_name")
    }

    output "argocd_webhook_setup" {
      value = tm_hcl_expression("module.eks.argocd_webhook_setup")
    }
  }
}
