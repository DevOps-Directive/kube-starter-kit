# Stack-specific configuration
globals "networking" {
  vpc_cidr                          = "10.0.0.0/16"
  nat_mode                          = "fck_nat"
  enable_bastion                    = true
  planetscale_endpoint_service_name = "com.amazonaws.vpce.us-east-2.vpce-svc-069f88c102c1a7fba"
}
