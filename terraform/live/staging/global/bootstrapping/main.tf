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
  context                     = module.this.context
}

# We create the bucket manually at first and then import it here to bootstrap the backend.
# See: terraform/bootstrap/Taskfile.yaml
import {
  to = module.account-bootstrapping.module.iam_role.aws_iam_role.this[0]
  id = "${module.this.id}-admin"
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
      type = "TXT"
      ttl  = 300
      # You could update this (and the corresponding value in the external-dns helm values to
      # restrict record ownership to a single external-dns instance
      records = ["heritage=external-dns,external-dns/owner=external-dns"]
    }
  }
}


