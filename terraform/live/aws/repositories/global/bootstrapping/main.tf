terraform {
  backend "s3" {
    bucket       = "kube-starter-kit-tf-state"
    key          = "aws/repositories/global/bootstrapping.tfstate"
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
    role_arn = "arn:aws:iam::857059614049:role/github-oidc-provider-aws-chain"
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

module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "6.2.1"

  name_prefix = "ecr-push"
  path        = "/"
  description = "Enable push access to all us-west-2 ECR repos in this AWS account"

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "ecr:GetAuthorizationToken",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "ecr:CompleteLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:InitiateLayerUpload",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage"
          ],
          "Resource": "arn:aws:ecr:us-west-2:857059614049:repository/*"
        }
      ]
    }
    EOF
}

module "github-oidc-provider" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "2.2.1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = ["DevOps-Directive/kube-starter-kit"]
  oidc_role_attach_policies = [module.iam_policy.arn]
}

