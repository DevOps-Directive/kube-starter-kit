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
  source = "../../../../modules//account-bootstrapping"
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
  region = "us-east-2"
  assume_role {
    role_arn = "${include.stage.inputs.terraform_iam_role_arn}"
  }
}
EOF
}

# Import the manually created bootstrap IAM role
# See: terraform/bootstrap/Taskfile.yaml
generate "imports" {
  path      = "imports.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
import {
  to = module.iam_role.aws_iam_role.this[0]
  id = "${include.root.inputs.namespace}-${include.environment.inputs.environment}-${include.stage.inputs.stage}-bootstrap-admin"
}
EOF
}

inputs = {
  # Module-specific inputs
  aws_region                  = "us-east-2"
  terraform_iam_role_arn      = include.stage.inputs.terraform_iam_role_arn
  github_oidc_assume_role_arn = include.root.inputs.github_oidc_assume_role_arn
  sso_admin_assume_role_arn   = include.root.inputs.sso_admin_assume_role_arn

  # Route53 zone
  create_zone             = true
  zone_name               = "staging.kubestarterkit.com"
  zone_external_dns_owner = "external-dns"

  # Cloudposse label context
  name        = "bootstrap"
  namespace   = include.root.inputs.namespace
  stage       = include.stage.inputs.stage
  environment = include.environment.inputs.environment
}