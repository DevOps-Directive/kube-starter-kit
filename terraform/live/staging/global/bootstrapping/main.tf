terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

locals {
  aws_assume_role_name = "github-oidc-provider-aws-chain"
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.terraform_iam_role_arn
  }
}

module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.2.1"

  name            = local.aws_assume_role_name
  use_name_prefix = false

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = ["sts:AssumeRole"]
      principals = [
        {
          type = "AWS"
          identifiers = [
            var.github_oidc_assume_role_arn,
            var.sso_admin_assume_role_arn
          ]
        }
      ]
    }
  }

  policies = { AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess" }

}


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
