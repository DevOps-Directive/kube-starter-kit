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
  # TODO: design private network CIDRs to split across VPCs
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  vpc_name = "${var.environment_name}-${var.aws_region}"

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
    "karpenter.sh/discovery" = "${var.environment_name}-${var.aws_region}"

  }
}

# Do we want to add randomness to the naming avoid collisions?
# resource "random_id" "server" {
#   # keepers = {
#   #   # Generate a new id each time we switch to a new AMI id
#   #   ami_id = var.ami_id
#   # }

#   byte_length = 8
#   prefix      = "nat-gw-${local.vpc_name}-${count.index}"
# }

module "fck-nat" {
  count   = var.nat_mode == "fck_nat" ? 3 : 0
  source  = "RaJiska/fck-nat/aws"
  version = "1.4.0"

  name                = "nat-gw-${local.vpc_name}-${count.index}"
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.public_subnets[count.index]
  instance_type       = "t4g.nano" # TODO: test to see if this becomes limiting (default for this is t4g.micro...)
  ha_mode             = true
  update_route_tables = true
  route_tables_ids    = { "private" : module.vpc.private_route_table_ids[count.index] }
}

# TODO: Add bastion host for private EKS connectivity
