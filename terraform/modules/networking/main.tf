terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  vpc_name = module.this.id
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.4.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  # TODO: do we want additional private subnets (e.g. database, elasticache, etc...)

  # TODO: should we initialize EIPs for NAT outside of module to enable carrying them across VPC lifecycle?
  enable_nat_gateway     = var.nat_mode != "fck_nat"
  single_nat_gateway     = var.nat_mode == "single_nat_gateway"
  one_nat_gateway_per_az = var.nat_mode == "one_nat_gateway_per_az"

  private_subnet_tags = {
    "karpenter.sh/discovery" = module.this.id
  }
}

# TODO: add vpc endpoints
# module "endpoints" {
#   source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
#   version = "6.4.0"

#   vpc_id = module.vpc.vpc_id
#   # security_group_ids = ["sg-12345678"]

#   endpoints = {
#     s3 = {
#       # interface endpoint
#       service = "s3"
#       tags    = { Name = "s3-vpc-endpoint" }
#     }
#   }
# }

# TODO: make planetscale VPC endpoint optional

# Private networking from VPC -> PlanetScale
# Verified!
#   root@ubuntu:/# dig +short aws-us-east-2.private-connect.psdb.cloudt-2.pri
#   10.0.1.104
#   10.0.2.131
#   10.0.0.161
#   root@ubuntu:/# curl https://aws-us-east-2.private-connect.psdb.cloud
#   Welcome to PlanetScale.
module "planetscale_vpce_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = "5.3.0"

  name        = "${module.this.id}-planetscale-vpce"
  description = "Ingress 443 from VPC to PlanetScale PrivateLink"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [module.vpc.vpc_cidr_block] # could instead allow ingress via specific SGs
}

module "planetscale_vpce" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "6.5.1"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.planetscale_vpce_sg.security_group_id]

  endpoints = {
    planetscale = {
      service_name        = var.planetscale_endpoint_service_name
      tags                = { Name = "planetscale-vpc-endpoint" }
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
  }
}

# NOTE: fck-nat module uses name var in naming of things like security group
#       if we wanted to deploy multiple VPCs to the same region, our current
#       naming convention would have a conflict:
#         ksk-use2-staging-network-nat-gw-0
# 
# Do we want to add randomness to the naming avoid collisions?
# resource "random_id" "server" {
#   # keepers = {
#   #   # Generate a new id each time we switch to a new AMI id
#   #   ami_id = var.ami_id
#   # }

module "fck-nat" {
  count   = var.nat_mode == "fck_nat" ? 3 : 0
  source  = "RaJiska/fck-nat/aws"
  version = "1.4.0"

  name                = "${local.vpc_name}-nat-gw-${count.index}"
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.public_subnets[count.index]
  instance_type       = var.fck-nat_instance_type
  ha_mode             = true
  update_route_tables = true
  route_tables_ids    = { "private" : module.vpc.private_route_table_ids[count.index] }
}

# TODO: Add bastion host for private EKS connectivity
