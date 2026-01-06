# Generate AWS provider configuration for stacks with terraform_iam_role_arn
generate_hcl "_provider.tf" {
  # Only generate if terraform_iam_role_arn is defined AND stack is not inline
  # Inline stacks have their own provider configuration in main.tf
  condition = tm_alltrue([
    tm_can(global.terraform_iam_role_arn),
    !tm_try(global.stack.inline, false)
  ])

  lets {
    # Filter enabled providers
    required_providers = {
      for k, v in tm_try(global.terraform.providers, {}) :
      k => {
        source  = v.source
        version = v.version
      } if tm_try(v.enabled, true)
    }
  }

  content {
    terraform {
      required_version = tm_try(global.terraform.version, "~> 1.6")

      tm_dynamic "required_providers" {
        attributes = let.required_providers
      }
    }

    provider "aws" {
      region = tm_try(global.aws_region, "us-east-2")

      assume_role {
        role_arn = global.terraform_iam_role_arn
      }
    }
  }
}
