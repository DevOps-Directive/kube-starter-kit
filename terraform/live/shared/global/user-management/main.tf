terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  region = var.aws_region
}

provider "aws" {
  region = local.region
  assume_role {
    role_arn = var.terraform_iam_role_arn
  }
}

# Auth:
#  - local: `gh auth login` (had to change scopes with `gh auth refresh -h github.com --scopes read:user,user:email,admin:org`)
#  - digger/gha: use octo-sts via TF_VAR_github_token (GITHUB_TOKEN is reserved for Terramate Cloud)
variable "github_token" {
  type        = string
  sensitive   = true
  default     = null # Falls back to GITHUB_TOKEN env var or gh CLI when null
  description = "GitHub token for provider authentication. Set via TF_VAR_github_token in CI."
}

provider "github" {
  owner = "DevOps-Directive"
  token = var.github_token
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context
}
