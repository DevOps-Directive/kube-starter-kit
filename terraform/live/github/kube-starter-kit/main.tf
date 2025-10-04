terraform {
  backend "s3" {
    bucket       = "kube-starter-kit-tf-state"
    key          = "github/kube-starter-kit.tfstate"
    region       = "us-east-2"
    use_lockfile = "true"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

provider "github" {
  owner = "DevOps-Directive"
}

resource "tls_private_key" "deploy_key" {
  algorithm = "ED25519"
}

# TODO: This can't be deployed with standard github action token permissions...
#       Need to figure out a way to automate (PAT or octo-sts)
# resource "github_repository_deploy_key" "example_repository_deploy_key" {
#   title      = "Repository test key"
#   repository = "kube-starter-kit"
#   key        = tls_private_key.deploy_key.public_key_openssh
#   read_only  = true
# }
