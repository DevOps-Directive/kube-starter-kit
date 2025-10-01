terraform {
  backend "s3" {
    bucket       = "kube-starter-kit-tf-state"
    key          = "aws/infrastructure/global/bootstrapping.tfstate"
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

provider "aws" {
  region = "us-east-2"
}

# TODO: Remove
resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "echo 'Hello World modified'"
  }
}
