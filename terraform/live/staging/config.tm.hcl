# Staging stage configuration
globals {
  stage                  = "staging"
  terraform_iam_role_arn = "arn:aws:iam::038198578795:role/ksk-gbl-staging-bootstrap-admin"
  sso_admin_role_arn     = "arn:aws:iam::038198578795:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_47aa578228eb79ff"
}
