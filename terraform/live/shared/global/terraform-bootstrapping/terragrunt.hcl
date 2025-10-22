include "root" {
  # This handles the dynamic backend setup
  path = find_in_parent_folders("root.hcl")
}

include "environment" {
  path = find_in_parent_folders("environment.hcl")
}

inputs = {
  stage = "infra"
  name = "bootstrap"
}