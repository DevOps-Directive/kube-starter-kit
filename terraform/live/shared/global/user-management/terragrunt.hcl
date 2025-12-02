include "root" {
  # This handles the dynamic backend setup
  path = find_in_parent_folders("root.hcl")
}

include "environment" {
  path = find_in_parent_folders("environment.hcl")
}

# TODO: handle terraform IAM role dynamically
#       if mock role is wrong... the plan wont actually work
#       I guess that is okay as long as we provide a way to execute the apply for only the upstream projects first
dependency "shared__global__manamgement_bootstrapping" {
  config_path = "../management-bootstrapping"

  # mock_outputs = {
  #   terraform_iam_role_arn = "arn:aws:iam::038198578795:role/github-oidc-provider-aws-chain"
  # }
  # mock_outputs_allowed_terraform_commands = ["plan"]
  # mock_outputs_merge_with_state = true
}

inputs = {
  terraform_iam_role_arn = dependency.shared__global__manamgement_bootstrapping.outputs.terraform_iam_role_arn
  stage = "mgmt"
  name = "user-management"
}