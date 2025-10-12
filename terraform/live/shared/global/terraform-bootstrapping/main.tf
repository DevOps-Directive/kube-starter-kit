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

module "github-oidc-provider" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "2.2.1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = ["DevOps-Directive/kube-starter-kit"]
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

# We create the bucket manually at first and then import it here to bootstrap the backend:
# aws s3api create-bucket \                                                     
#   --bucket kube-starter-kit-tf-state \       
#   --region us-east-2 \
#   --create-bucket-configuration LocationConstraint=us-east-2
import {
  to = module.state-bucket.aws_s3_bucket.this[0]
  id = "kube-starter-kit-tf-state" # TODO move to input variable
}


module "state-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket = "kube-starter-kit-tf-state"

  versioning = {
    enabled = true
  }
}

module "plans-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket = "kube-starter-kit-tf-digger-plans"

  versioning = {
    enabled = true
  }
}

