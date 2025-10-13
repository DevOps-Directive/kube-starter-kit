terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

module "networking" {
  source = "../../../../modules/networking"

  environment_name       = var.environment_name
  aws_region             = var.aws_region
  terraform_iam_role_arn = var.terraform_iam_role_arn

}
