# Stack-specific configuration
globals "networking" {
  vpc_cidr                          = "10.1.0.0/16" # Different from us-east-2's 10.0.0.0/16
  nat_mode                          = "fck_nat"
  enable_bastion                    = true
  planetscale_endpoint_service_name = "com.amazonaws.vpce.us-east-1.vpce-svc-02fef31be60d3fd35"
}
