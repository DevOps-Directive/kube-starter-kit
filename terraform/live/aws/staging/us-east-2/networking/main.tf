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

provider "aws" {
  region = "us-east-2"
}

resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "echo 'Hello World'"
  }
}
