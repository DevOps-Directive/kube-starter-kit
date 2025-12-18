# Stack-specific configuration
globals "networking" {
  vpc_cidr                          = "10.2.0.0/16" # Different CIDR for prod
  nat_mode                          = "one_nat_gateway_per_az" # Real NAT gateway for production
  enable_bastion                    = true
  planetscale_endpoint_service_name = "com.amazonaws.vpce.us-east-2.vpce-svc-069f88c102c1a7fba"
}
