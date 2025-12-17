# Staging stage configuration
globals {
  stage                  = "staging"
  terraform_iam_role_arn = "arn:aws:iam::038198578795:role/ksk-gbl-staging-bootstrap-admin"
  sso_admin_role_arn     = "arn:aws:iam::038198578795:role/AWSReservedSSO_AdministratorAccess_c43fd52097fda498"
}
