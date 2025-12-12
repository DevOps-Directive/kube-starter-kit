include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "stage" {
  path   = find_in_parent_folders("stage.hcl")
  expose = true
}

include "environment" {
  path   = find_in_parent_folders("environment.hcl")
  expose = true
}

terraform {
  source = "../../../../modules//networking"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "${include.environment.inputs.aws_region}"
  assume_role {
    role_arn = "${include.stage.inputs.terraform_iam_role_arn}"
  }
}
EOF
}

inputs = {
  # Module-specific inputs
  environment_name           = include.stage.inputs.stage
  aws_region                 = include.environment.inputs.aws_region
  terraform_iam_role_arn     = include.stage.inputs.terraform_iam_role_arn
  nat_mode                   = "fck_nat"
  vpc_cidr                   = "10.10.0.0/16"  # Different CIDR for production
  planetscale_endpoint_service_name = "com.amazonaws.vpce.us-east-2.vpce-svc-069f88c102c1a7fba"

  # Cloudposse label context
  name        = "network"
  namespace   = include.root.inputs.namespace
  stage       = include.stage.inputs.stage
  environment = include.environment.inputs.environment
}
