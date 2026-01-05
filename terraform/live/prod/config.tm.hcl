# Production stage configuration (example - separate AWS account)
globals {
  stage                  = "prod"
  terraform_iam_role_arn = "DUMMY" # (putting invalid ARN here to prevent deploying prod for now)
  # terraform_iam_role_arn = "arn:aws:iam::964263445142:role/ksk-gbl-prod-bootstrap-admin"

  # SSO role granted admin access to EKS clusters
  admin_sso_role_arn = "arn:aws:iam::964263445142:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_61e32a1d3786074b"

  # Production uses pinned module versions from git tags (managed by release-please)
  # This allows validating module changes in staging before promoting to production.
  # Update these versions after release-please creates new tags.
  modules = {
    use_pinned_versions = true
    git_base_url        = "git::https://github.com/DevOps-Directive/kube-starter-kit.git"
    versions = {
      account_bootstrapping    = "0.1.0"
      eks                      = "0.1.0"
      networking               = "0.1.0"
      app_resources_go_backend = "0.1.0"
    }
  }
}
