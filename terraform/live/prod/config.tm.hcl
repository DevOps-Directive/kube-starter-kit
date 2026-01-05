# Production stage configuration (example - separate AWS account)
globals {
  stage                  = "prod"
  terraform_iam_role_arn = "DUMMY" # (putting invalid ARN here to prevent deploying prod for now) "arn:aws:iam::964263445142:role/ksk-gbl-prod-bootstrap-admin"
  # SSO role granted admin access to EKS clusters
  admin_sso_role_arn     = "arn:aws:iam::964263445142:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_61e32a1d3786074b"
}
