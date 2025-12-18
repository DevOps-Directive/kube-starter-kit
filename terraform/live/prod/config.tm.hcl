# Production stage configuration (example - separate AWS account)
globals {
  stage                  = "prod"
  terraform_iam_role_arn = "arn:aws:iam::964263445142:role/ksk-gbl-prod-bootstrap-admin"
  sso_admin_role_arn     = "arn:aws:iam::964263445142:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_61e32a1d3786074b"
}
