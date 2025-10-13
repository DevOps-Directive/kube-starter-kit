include "root" {
  # This handles the dynamic backend setup
  path = find_in_parent_folders("root.hcl")
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
    private_subnets = ["PLACEHOLDER_sub1","PLACEHOLDER_sub2","PLACEHOLDER_sub3"]
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
  mock_outputs_merge_with_state = true
}


inputs = {
  environment_name= "staging"
  aws_region = "us-east-2"
  terraform_iam_role_arn = dependency.staging__global__bootstrapping.outputs.terraform_iam_role_arn
  vpc_id = dependency.staging__us_east_2__networking.outputs.vpc_id
  private_subnets = dependency.staging__us_east_2__networking.outputs.private_subnets
}