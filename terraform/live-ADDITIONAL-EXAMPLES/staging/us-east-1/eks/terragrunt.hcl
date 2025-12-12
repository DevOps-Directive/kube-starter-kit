include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "stage" {
  path = find_in_parent_folders("stage.hcl")
}

include "environment" {
  path = find_in_parent_folders("environment.hcl")
}

dependency "staging__global__bootstrapping" {
  config_path = "../../global/bootstrapping"
}

dependency "staging__us_east_1__networking" {
  config_path = "../networking"

  mock_outputs = {
    vpc_id = "PLACEHOLDER_VPC_ID"
    private_subnets = ["PLACEHOLDER_sub1","PLACEHOLDER_sub2","PLACEHOLDER_sub3"]
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
  mock_outputs_merge_with_state = true
}

inputs = {
  route53_zone_arn = dependency.staging__global__bootstrapping.outputs.zone_arn
  vpc_id = dependency.staging__us_east_1__networking.outputs.vpc_id
  private_subnets = dependency.staging__us_east_1__networking.outputs.private_subnets
}
