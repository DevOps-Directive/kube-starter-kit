# Account bootstrapping module generation for stacks tagged with "bootstrapping"
# Generates main.tf with module call
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

generate_hcl "main.tf" {
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
