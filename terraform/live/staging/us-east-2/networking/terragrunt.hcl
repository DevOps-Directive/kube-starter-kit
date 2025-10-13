include "root" {
  # This handles the dynamic backend setup
  path = find_in_parent_folders("root.hcl")
}

# NOTE: Bootstrapping units must be applied first!
#       Intentionally didn't mock since it would require a manual copy paste
dependency "staging__global__bootstrapping" {
  config_path = "../../global/bootstrapping"
}

inputs = {
  environment_name = "staging"
  aws_region = "us-east-2"
  terraform_iam_role_arn = dependency.staging__global__bootstrapping.outputs.terraform_iam_role_arn
}