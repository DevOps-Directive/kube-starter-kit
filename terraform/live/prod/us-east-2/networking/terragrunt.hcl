include "root" {
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
  vpc_cidr = "10.10.0.0/16"  # Different CIDR for production
  planetscale_endpoint_service_name = "com.amazonaws.vpce.us-east-2.vpce-svc-069f88c102c1a7fba"
}
