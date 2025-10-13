terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

module "eks-wrapper" {
  source = "../../../../modules/eks"

  environment_name       = var.environment_name
  aws_region             = var.aws_region
  terraform_iam_role_arn = var.terraform_iam_role_arn
  vpc_id                 = var.vpc_id
  private_subnets        = var.private_subnets

}
