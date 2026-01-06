# Staging stage configuration
globals {
  stage                  = "staging"
  terraform_iam_role_arn = "arn:aws:iam::038198578795:role/ksk-gbl-staging-bootstrap-admin"
  # SSO role granted admin access to EKS clusters
  admin_sso_role_arn = "arn:aws:iam::038198578795:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_47aa578228eb79ff"

  # Staging uses local module paths (relative to stack) for rapid iteration.
  # Changes to modules are immediately reflected when running terraform plan/apply.
  modules = {
    use_pinned_versions = false
  }
}
