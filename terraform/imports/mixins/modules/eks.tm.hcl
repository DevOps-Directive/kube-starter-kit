# EKS module generation for stacks tagged with "eks"
# Generates main.tf with module call and _outputs.tm.hcl for outputs sharing
#
# Required globals:
#   - global.namespace
#   - global.stage  
#   - global.environment
#   - global.aws_region
#   - global.terraform_iam_role_arn
#   - global.sso_admin_role_arn
#   - global.eks.kubernetes_version
#   - global.eks.base_node_group_kubernetes_version
#   - global.eks.endpoint_public_access
#   - global.eks.endpoint_private_access
#   - global.eks.argocd_hostname
#
# Required inputs (from outputs sharing):
#   - vpc_id (from networking stack)
#   - vpc_cidr (from networking stack)
#   - private_subnets (from networking stack)
#   - route53_zone_arn (from bootstrapping stack)

generate_hcl "_main.tf" {
  condition = tm_contains(terramate.stack.tags, "eks")

  content {
    module "eks" {
      source = "${terramate.stack.path.to_root}/terraform/modules//eks"

      # CloudPosse context
      name        = "eks"
      namespace   = global.namespace
      stage       = global.stage
      environment = global.environment

      # From globals
      aws_region             = global.aws_region
      terraform_iam_role_arn = global.terraform_iam_role_arn
      admin_sso_role_arn     = global.sso_admin_role_arn

      # From inputs (outputs sharing) - these become variables
      vpc_id           = tm_hcl_expression("var.vpc_id")
      vpc_cidr         = tm_hcl_expression("var.vpc_cidr")
      private_subnets  = tm_hcl_expression("var.private_subnets")
      route53_zone_arn = tm_hcl_expression("var.route53_zone_arn")

      # Stack-specific config from globals
      kubernetes_version                 = global.eks.kubernetes_version
      base_node_group_kubernetes_version = global.eks.base_node_group_kubernetes_version
      endpoint_public_access             = global.eks.endpoint_public_access
      endpoint_private_access            = global.eks.endpoint_private_access
      argocd_hostname                    = global.eks.argocd_hostname
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

    output "eks_cluster_endpoint" {
      backend = "terraform"
      value   = tm_hcl_expression("module.eks.eks_cluster_endpoint")
    }

    output "deploy_key_public_key" {
      backend = "terraform"
      value   = tm_hcl_expression("module.eks.deploy_key_public_key")
    }

    output "deploy_key_setup" {
      backend = "terraform"
      value   = tm_hcl_expression("module.eks.deploy_key_setup")
    }

    output "karpenter_interruption_queue" {
      backend = "terraform"
      value   = tm_hcl_expression("module.eks.karpenter_interruption_queue")
    }

    output "karpenter_node_role_name" {
      backend = "terraform"
      value   = tm_hcl_expression("module.eks.karpenter_node_role_name")
    }

    output "argocd_webhook_setup" {
      backend = "terraform"
      value   = tm_hcl_expression("module.eks.argocd_webhook_setup")
    }
  }
}
