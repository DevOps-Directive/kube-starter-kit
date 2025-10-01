terraform {
  backend "s3" {
    bucket       = "kube-starter-kit-tf-state"
    key          = "aws/staging/us-east-2/networking.tfstate"
    region       = "us-east-2"
    use_lockfile = "true"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  name   = "infrastructure"
  region = "us-west-2"

  # TODO: design private network CIDRs to split across VPCs
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

}

provider "aws" {
  region = "us-east-2"

  # TODO: chain role to deploy into staging account
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

  enable_nat_gateway = false # use https://fck-nat.dev/ instead
}

module "fck-nat" {
  count   = 3
  source  = "RaJiska/fck-nat/aws"
  version = "1.4.0"

  name                = "nat-gw-${count.index}"
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.public_subnets[count.index]
  ha_mode             = true
  update_route_tables = true
  route_tables_ids    = { "private" : module.vpc.private_route_table_ids[count.index] }
}
