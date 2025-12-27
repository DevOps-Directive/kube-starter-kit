terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region              = "us-east-2"
  allowed_account_ids = ["094905625236"]
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context
}

module "github-oidc-provider" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "2.2.1"

  role_name = "${module.label.id}-github-oidc"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = ["DevOps-Directive/kube-starter-kit"]
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

# We create the bucket manually at first and then import it here to bootstrap the backend.
# See: terraform/bootstrap/mise.toml
# import {
#   to = module.state-bucket.aws_s3_bucket.this[0]
#   id = "${module.label.id}-state"
# }


module "state-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket        = "${module.label.id}-state"
  force_destroy = true

  versioning = {
    enabled = true
  }
}

module "plans-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket        = "${module.label.id}-digger-plans"
  force_destroy = true

  versioning = {
    enabled = true
  }
}



