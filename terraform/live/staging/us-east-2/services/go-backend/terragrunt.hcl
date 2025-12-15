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
  source = "../../../../../modules/services//go-backend"
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

dependency "eks" {
  config_path = "../../eks"

  mock_outputs = {
    eks_cluster_name = "PLACEHOLDER_CLUSTER_NAME"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  # EKS cluster configuration
  eks_cluster_name = dependency.eks.outputs.eks_cluster_name

  # Kubernetes configuration
  kubernetes_namespace       = "go-backend-kustomize"
  kubernetes_service_account = "go-backend"

  # S3 bucket configuration
  force_destroy             = true # Set to false for production
  bucket_versioning_enabled = true

  # CloudPosse label context
  name        = "go-backend"
  namespace   = include.root.inputs.namespace
  stage       = include.stage.inputs.stage
  environment = include.environment.inputs.environment
}
