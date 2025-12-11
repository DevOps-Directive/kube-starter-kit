terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.terraform_iam_role_arn
  }
}

# Auth:
#  - local: `gh auth login` (requires admin:repo_hook scope)
#  - CI/CD: use GITHUB_TOKEN or GitHub App
provider "github" {
  owner = "DevOps-Directive"
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "eks"
  context = module.this.context
}

module "eks-wrapper" {
  source = "../../../../modules/eks"

  aws_region             = var.aws_region
  terraform_iam_role_arn = var.terraform_iam_role_arn
  route53_zone_arn       = var.route53_zone_arn
  vpc_id                 = var.vpc_id
  private_subnets        = var.private_subnets
  sso_admin_role_arn     = var.sso_admin_role_arn
  context                = module.label.context

  # ArgoCD webhook configuration
  argocd_hostname = "argocd.staging.kubestarterkit.com"
}
