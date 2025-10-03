terraform {
  backend "s3" {
    bucket       = "kube-starter-kit-tf-state"
    key          = "aws/repositories/us-east-2/repositories.tfstate"
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

locals {
  region = "us-east-2"
  repos = [
    "foo",
    "bar",
    "baz"
  ]
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = local.region
  assume_role {
    role_arn = "arn:aws:iam::857059614049:role/github-oidc-provider-aws-chain"
  }
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "3.1.0"

  for_each        = local.repos
  repository_name = each.value

  repository_read_access_arns = [
    "arn:aws:iam::038198578795:root", # TODO: establish better pattern for looking up account IDs
    "arn:aws:iam::964263445142:root",
  ]
  create_lifecycle_policy = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images with v* tags"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 100 total images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 100
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_force_delete = true

  repository_image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  repository_image_tag_mutability_exclusion_filter = [
    {
      filter      = "dev-*"
      filter_type = "WILDCARD"
    },
    {
      filter      = "staging-*"
      filter_type = "WILDCARD"
    }
  ]
}
