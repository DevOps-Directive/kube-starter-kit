# EKS module generation for stacks tagged with "eks"
# Generates main.tf with module call
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

generate_hcl "main.tf" {
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
