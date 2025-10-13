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

# This could move out of this root module if additional instances are needed are needed
module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "6.2.1"

  name_prefix = "ecr-push"
  path        = "/"
  description = "Enable push access to all us-west-2 ECR repos in this AWS account"

  policy = <<-EOF
    {
        "Version":"2012-10-17",		 	 	 
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "ecr:CompleteLayerUpload",
                    "ecr:GetAuthorizationToken",
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
