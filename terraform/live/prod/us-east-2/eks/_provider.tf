// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}
provider "aws" {
  region = "us-east-2"
  assume_role {
    role_arn = "arn:aws:iam::964263445142:role/ksk-gbl-prod-bootstrap-admin"
  }
}
