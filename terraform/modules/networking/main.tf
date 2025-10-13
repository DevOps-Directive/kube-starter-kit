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
  name   = "staging"
  region = var.aws_region

  # TODO: design private network CIDRs to split across VPCs
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.4.0"

  name = "${local.name}-${local.region}"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  # TODO: do we want additional private subnets (e.g. database, elasticache, etc...)

  enable_nat_gateway     = var.nat_mode != "fck_nat"
  single_nat_gateway     = var.nat_mode == "single_nat_gateway"
  one_nat_gateway_per_az = var.nat_mode == "one_nat_gateway_per_az"

  private_subnet_tags = {
    "karpenter.sh/discovery" = "${local.name}-${local.region}"

  }
}

module "fck-nat" {
  count   = var.nat_mode == "fck_nat" ? 3 : 0
  source  = "RaJiska/fck-nat/aws"
  version = "1.4.0"

  name                = "nat-gw-${count.index}"
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.public_subnets[count.index]
  instance_type       = "t4g.nano" # TODO: test to see if this becomes limiting (default for this is t4g.micro...)
  ha_mode             = true
  update_route_tables = true
  route_tables_ids    = { "private" : module.vpc.private_route_table_ids[count.index] }
}

# TODO: Add bastion host for private EKS connectivity
