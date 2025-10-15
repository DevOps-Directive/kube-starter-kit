terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.terraform_iam_role_arn
  }
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
}

# We create the role manually at first and then import it here to bootstrap access.
# See: terraform/bootstrap/Taskfile.yaml
import {
  to = module.account-bootstrapping.module.iam_role.aws_iam_role.this[0]
  id = "${module.label.id}-admin"
}

module "account-bootstrapping" {
  source = "../../../../modules/account-bootstrapping"

  aws_region                  = var.aws_region
  terraform_iam_role_arn      = var.terraform_iam_role_arn
  github_oidc_assume_role_arn = var.github_oidc_assume_role_arn
  sso_admin_assume_role_arn   = var.sso_admin_assume_role_arn
  context                     = module.label.context
}


