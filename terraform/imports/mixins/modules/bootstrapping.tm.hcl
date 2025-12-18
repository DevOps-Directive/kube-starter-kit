# Account bootstrapping module generation for stacks tagged with "bootstrapping"
# Generates main.tf with module call and _outputs.tm.hcl for outputs sharing
#
# Note: Only applies to environment-specific bootstrapping stacks (staging, prod)
# Shared bootstrapping stacks (terraform-bootstrapping, ecr-repositories-bootstrapping, etc.)
# have inline main.tf files and are excluded via the !shared condition.
#
# Required globals:
#   - global.namespace
#   - global.stage
#   - global.environment
#   - global.terraform_iam_role_arn
#   - global.github_oidc_assume_role_arn
#   - global.sso_admin_assume_role_arn
#   - global.bootstrapping.aws_region
#   - global.bootstrapping.create_zone
#   - global.bootstrapping.zone_name
#   - global.bootstrapping.zone_external_dns_owner

generate_hcl "_main.tf" {
  # Only generate for environment-specific bootstrapping, not shared inline stacks
  condition = tm_alltrue([
    tm_contains(terramate.stack.tags, "bootstrapping"),
    !tm_contains(terramate.stack.tags, "shared"),
  ])

  content {
    module "bootstrapping" {
      source = "${terramate.stack.path.to_root}/terraform/modules//account-bootstrapping"

      # CloudPosse context
      name        = "bootstrap"
      namespace   = global.namespace
      stage       = global.stage
      environment = global.environment

      # Module inputs
      aws_region                  = global.bootstrapping.aws_region
      terraform_iam_role_arn      = global.terraform_iam_role_arn
      github_oidc_assume_role_arn = global.github_oidc_assume_role_arn
      sso_admin_assume_role_arn   = global.sso_admin_assume_role_arn

      # Route53 zone
      create_zone             = global.bootstrapping.create_zone
      zone_name               = global.bootstrapping.zone_name
      zone_external_dns_owner = global.bootstrapping.zone_external_dns_owner
    }
  }
}

# Generate outputs for sharing with dependent stacks
# Note: Requires running `terramate generate` twice - first creates this file,
# second run parses it and updates _sharing.tf
generate_hcl "_outputs.tm.hcl" {
  # Only generate for environment-specific bootstrapping, not shared inline stacks
  condition = tm_alltrue([
    tm_contains(terramate.stack.tags, "bootstrapping"),
    !tm_contains(terramate.stack.tags, "shared"),
  ])

  content {
    output "terraform_iam_role_arn" {
      backend = "terraform"
      value   = tm_hcl_expression("module.bootstrapping.terraform_iam_role_arn")
    }

    output "zone_arn" {
      backend = "terraform"
      value   = tm_hcl_expression("module.bootstrapping.zone_arn")
    }
  }
}

# Generate informational outputs (not shared with other stacks)
generate_hcl "_outputs_info.tf" {
  # Only generate for environment-specific bootstrapping, not shared inline stacks
  condition = tm_alltrue([
    tm_contains(terramate.stack.tags, "bootstrapping"),
    !tm_contains(terramate.stack.tags, "shared"),
  ])

  content {
    output "zone_name_servers" {
      value = tm_hcl_expression("module.bootstrapping.zone_name_servers")
    }
  }
}
