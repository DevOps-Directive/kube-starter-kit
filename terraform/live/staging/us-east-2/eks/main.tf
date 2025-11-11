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
  name    = "eks"
  context = module.this.context
}


module "eks-wrapper" {
  source = "../../../../modules/eks"

  aws_region             = var.aws_region
  terraform_iam_role_arn = var.terraform_iam_role_arn
  route53_zone_arn       = var.route53_zone_arn
  vpc_id                 = var.vpc_id
  private_subnets        = var.private_subnets
  sso_admin_role_arn     = var.sso_admin_role_arn
  context                = module.label.context
}
