include "root" {
  # This handles the dynamic backend setup
  path = find_in_parent_folders("root.hcl")
}

include "stage" {
  path = find_in_parent_folders("stage.hcl")
}

include "environment" {
  path = find_in_parent_folders("environment.hcl")
}

inputs = {
  nat_mode = "fck_nat"
  vpc_cidr = "10.0.0.0/16"
}