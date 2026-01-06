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
#
# Module source configuration:
#   - When global.modules.use_pinned_versions is true: uses git source with pinned tag
#   - When false (default): uses local relative path for rapid iteration

generate_hcl "_main.tf" {
  condition = tm_contains(terramate.stack.tags, "networking")

  lets {
    # Determine module source based on configuration
    use_pinned    = tm_try(global.modules.use_pinned_versions, false)
    local_source  = "${terramate.stack.path.to_root}/terraform/modules//networking"
    pinned_source = "${tm_try(global.modules.git_base_url, "")}//terraform/modules/networking?ref=terraform/modules/networking@${tm_try(global.modules.versions.networking, "0.1.0")}"
    module_source = let.use_pinned ? let.pinned_source : let.local_source
  }

  content {
    module "networking" {
      source = let.module_source

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
generate_hcl "_outputs_shared.tm.hcl" {
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
  }
}

# Generate informational outputs (not shared with other stacks)
generate_hcl "_outputs_info.tf" {
  condition = tm_contains(terramate.stack.tags, "networking")

  content {
    output "public_subnets" {
      value = tm_hcl_expression("module.networking.public_subnets")
    }

    output "bastion_instance_id" {
      value = tm_hcl_expression("module.networking.bastion_instance_id")
    }
  }
}
