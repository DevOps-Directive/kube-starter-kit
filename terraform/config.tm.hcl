# Root-level globals - inherited by all stacks
globals {
  # Organization-wide constants
  namespace = "ksk"

  # GitHub OIDC role in the "infra" account (for CI/CD)
  github_oidc_assume_role_arn = "arn:aws:iam::094905625236:role/ksk-gbl-infra-bootstrap-github-oidc"
  sso_admin_assume_role_arn   = "arn:aws:iam::094905625236:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_80ecc41059967962"

  # S3 backend configuration
  backend_bucket = "ksk-gbl-infra-bootstrap-state"
  backend_region = "us-east-2"

  # Default Terraform configuration
  terraform = {
    version = "~> 1.6"
    providers = {
      aws = {
        source  = "hashicorp/aws"
        version = "6.27.0"
        enabled = true
      }
      random = {
        source  = "hashicorp/random"
        version = "~> 3.0"
        enabled = false
      }
    }
  }
}
