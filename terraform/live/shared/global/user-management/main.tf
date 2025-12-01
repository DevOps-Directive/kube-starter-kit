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
#  - digger/gha: use octo-sts
provider "github" {
  owner = "DevOps-Directive"
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context
}
