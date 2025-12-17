# Root-level globals - inherited by all stacks
globals {
  # Organization-wide constants
  namespace = "ksk"

  # GitHub OIDC role in the "infra" account (for CI/CD)
  github_oidc_assume_role_arn = "arn:aws:iam::038198578795:role/github-oidc-provider-aws-chain"
  sso_admin_assume_role_arn   = "arn:aws:iam::038198578795:role/AWSReservedSSO_AdministratorAccess_c43fd52097fda498"

  # S3 backend configuration
  backend_bucket = "ksk-gbl-infra-bootstrap-state"
  backend_region = "us-east-2"

  # Default Terraform configuration
  terraform = {
    version = "~> 1.6"
    providers = {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 6.0"
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
