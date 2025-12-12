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
  vpc_cidr = "10.1.0.0/16"  # Different from us-east-2's 10.0.0.0/16
  planetscale_endpoint_service_name = "com.amazonaws.vpce.us-east-1.vpce-svc-02fef31be60d3fd35"
}
