# Networking module generation for stacks tagged with "networking"
# Generates main.tf with module call
#
# Required globals:
#   - global.namespace
#   - global.stage
#   - global.environment
#   - global.aws_region
#   - global.terraform_iam_role_arn
#   - global.networking.vpc_cidr
#   - global.networking.nat_mode
#   - global.networking.enable_bastion
#   - global.networking.planetscale_endpoint_service_name

generate_hcl "main.tf" {
  condition = tm_contains(terramate.stack.tags, "networking")

  content {
    module "networking" {
      source = "${terramate.stack.path.to_root}/terraform/modules//networking"

      # CloudPosse context
      name        = "network"
      namespace   = global.namespace
      stage       = global.stage
      environment = global.environment

      # Module inputs
      environment_name       = global.stage
      aws_region             = global.aws_region
      terraform_iam_role_arn = global.terraform_iam_role_arn

      vpc_cidr       = global.networking.vpc_cidr
      nat_mode       = global.networking.nat_mode
      enable_bastion = global.networking.enable_bastion

      planetscale_endpoint_service_name = global.networking.planetscale_endpoint_service_name
    }
  }
}
