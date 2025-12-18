# Networking module generation for stacks tagged with "networking"
# Generates main.tf with module call and _outputs.tm.hcl for outputs sharing
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

generate_hcl "_main.tf" {
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

# Generate outputs for sharing with dependent stacks
# Note: Requires running `terramate generate` twice - first creates this file,
# second run parses it and updates _sharing.tf
generate_hcl "_outputs.tm.hcl" {
  condition = tm_contains(terramate.stack.tags, "networking")

  content {
    output "vpc_id" {
      backend = "terraform"
      value   = tm_hcl_expression("module.networking.vpc_id")
    }

    output "vpc_cidr" {
      backend = "terraform"
      value   = tm_hcl_expression("module.networking.vpc_cidr")
    }

    output "private_subnets" {
      backend = "terraform"
      value   = tm_hcl_expression("module.networking.private_subnets")
    }

    output "public_subnets" {
      backend = "terraform"
      value   = tm_hcl_expression("module.networking.public_subnets")
    }

    output "bastion_instance_id" {
      backend = "terraform"
      value   = tm_hcl_expression("module.networking.bastion_instance_id")
    }
  }
}
