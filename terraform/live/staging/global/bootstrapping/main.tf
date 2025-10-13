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

module "account-bootstrapping" {
  source = "../../../../modules/account-bootstrapping"

  aws_region                  = var.aws_region
  terraform_iam_role_arn      = var.terraform_iam_role_arn
  github_oidc_assume_role_arn = var.github_oidc_assume_role_arn
  sso_admin_assume_role_arn   = var.sso_admin_assume_role_arn
}

# We create this role manually at first and then import it here to bootstrap access
import {
  to = module.account-bootstrapping.module.iam_role.aws_iam_role.this[0]
  id = "github-oidc-provider-aws-chain"
}

moved {
  from = module.iam_role
  to   = module.account-bootstrapping.module.iam_role
}

# This should probablty move out of this root module (But it didn't really belong with "account-bootstrapping")
module "zone" {
  source  = "terraform-aws-modules/route53/aws"
  version = "6.1.0"

  name = "staging.kubestarterkit.com"

  # Enables external-dns to update records for staging.kubestarterkit.com
  # Without this, it will create a record initially, but will not update/delete
  records = {
    _extdns = {
      type    = "TXT"
      ttl     = 300
      records = ["heritage=external-dns,external-dns/owner=staging-us-east-2"]
    }
  }
}

