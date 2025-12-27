# Account bootstrapping module generation for stacks tagged with "bootstrapping"
# Generates _main.tf with import block and module call, plus _outputs.tm.hcl for outputs sharing
#
# Applies to all bootstrapping stacks: staging, prod, management, ecr
# Excludes terraform-bootstrapping (infra account) which has different requirements.
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
  # Generate for all bootstrapping stacks except terraform-bootstrapping (infra account)
  condition = tm_alltrue([
    tm_contains(terramate.stack.tags, "bootstrapping"),
    !tm_contains(terramate.stack.tags, "infra"),
  ])

  content {
    # Import the IAM role that was manually created during bootstrap.
    # This is necessary because Terraform needs the role to exist before it can
    # manage cross-account access, but we also want Terraform to manage the role
    # going forward (e.g., to add GitHub OIDC trust for CI/CD).
    #
    # Note: import blocks must be in root modules, not child modules.
    import {
      to = tm_hcl_expression("module.bootstrapping.module.iam_role.aws_iam_role.this[0]")
      id = "${global.namespace}-${global.environment}-${global.stage}-bootstrap-admin"
    }

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
  # Generate for all bootstrapping stacks except terraform-bootstrapping (infra account)
  condition = tm_alltrue([
    tm_contains(terramate.stack.tags, "bootstrapping"),
    !tm_contains(terramate.stack.tags, "infra"),
  ])

  content {
    output "terraform_iam_role_arn" {
      backend = "terraform"
      value   = tm_hcl_expression("module.bootstrapping.terraform_iam_role_arn")
    }

    # Only output zone_arn when a zone is created
    tm_dynamic "output" {
      labels    = ["zone_arn"]
      condition = global.bootstrapping.create_zone
      attributes = {
        backend = "terraform"
        value   = tm_hcl_expression("module.bootstrapping.zone_arn")
      }
    }
  }
}

# Generate informational outputs (not shared with other stacks)
# Only generated when a Route53 zone is created
generate_hcl "_outputs_info.tf" {
  condition = tm_alltrue([
    tm_contains(terramate.stack.tags, "bootstrapping"),
    !tm_contains(terramate.stack.tags, "infra"),
    tm_try(global.bootstrapping.create_zone, false),
  ])

  content {
    output "zone_name_servers" {
      value = tm_hcl_expression("module.bootstrapping.zone_name_servers")
    }
  }
}
