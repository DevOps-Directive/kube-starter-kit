terraform {
  backend "s3" {
    bucket       = "kube-starter-kit-tf-state"
    key          = "aws/staging/global/bootstrapping.tfstate"
    region       = "us-east-2"
    use_lockfile = "true"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  assume_role {
    role_arn = "arn:aws:iam::038198578795:role/github-oidc-provider-aws-chain"
  }
}

module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.2.1"

  name            = "github-oidc-provider-aws-chain"
  use_name_prefix = false

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = ["sts:AssumeRole"]
      principals = [
        {
          type = "AWS"
          identifiers = [
            "arn:aws:iam::094905625236:role/github-oidc-provider-aws",                                                                       # TODO: look up from remote state
            "arn:aws:iam::094905625236:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AWSAdministratorAccess_fa7ea65862c3f54a" # TODO: establish better way to look this up (or create an extra role in the infra account to chain)
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
