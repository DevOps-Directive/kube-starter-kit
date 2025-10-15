include "root" {
  # This handles the dynamic backend setup
  path = find_in_parent_folders("root.hcl")
  expose = true
}

include "stage" {
  path = find_in_parent_folders("stage.hcl")
}

include "environment" {
  path = find_in_parent_folders("environment.hcl")
}

inputs = {
  aws_region = "us-east-2"
  name = "bootstrap"
}