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
  name    = "network"
  context = module.this.context
}

module "networking" {
  source = "../../../../modules/networking"

  environment_name       = var.stage
  aws_region             = var.aws_region
  terraform_iam_role_arn = var.terraform_iam_role_arn
  nat_mode               = var.nat_mode
  context                = module.label.context
}
