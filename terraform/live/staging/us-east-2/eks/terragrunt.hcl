include "root" {
  # This handles the dynamic backend setup
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
  source = "../../../../modules//eks"
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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
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

# NOTE: Bootstrapping units must be applied first!
#       Intentionally didn't mock since it would require a manual copy paste
dependency "staging__global__bootstrapping" {
  config_path = "../../global/bootstrapping"
}

dependency "staging__us_east_2__networking" {
  config_path = "../networking"

  mock_outputs = {
    vpc_id = "PLACEHOLDER_VPC_ID"
    vpc_cidr = "10.0.0.0/16"
    private_subnets = ["PLACEHOLDER_sub1","PLACEHOLDER_sub2","PLACEHOLDER_sub3"]
    public_subnets = ["PLACEHOLDER_pub1","PLACEHOLDER_pub2","PLACEHOLDER_pub3"]
    bastion_instance_id = "PLACEHOLDER_BASTION_ID"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
  mock_outputs_merge_with_state = true
}

inputs = {
  # Module-specific inputs
  aws_region             = include.environment.inputs.aws_region
  terraform_iam_role_arn = include.stage.inputs.terraform_iam_role_arn
  admin_sso_role_arn     = include.stage.inputs.sso_admin_role_arn
  route53_zone_arn       = dependency.staging__global__bootstrapping.outputs.zone_arn
  vpc_id                 = dependency.staging__us_east_2__networking.outputs.vpc_id
  vpc_cidr               = dependency.staging__us_east_2__networking.outputs.vpc_cidr
  private_subnets        = dependency.staging__us_east_2__networking.outputs.private_subnets

  # Private endpoint - access via bastion SOCKS proxy
  endpoint_public_access  = false
  endpoint_private_access = true

  kubernetes_version = "1.34"
  base_node_group_kubernetes_version = "1.34"

  # ArgoCD webhook configuration
  argocd_hostname = "argocd.staging.kubestarterkit.com"

  # Cloudposse label context
  name        = "eks"
  namespace   = include.root.inputs.namespace
  stage       = include.stage.inputs.stage
  environment = include.environment.inputs.environment
}
