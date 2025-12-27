stack {
  id          = "shared-gbl-ecr-repositories-bootstrapping"
  name        = "ecr-repositories-bootstrapping"
  description = "Bootstrap IAM for ECR account"
  tags        = ["shared", "global", "bootstrapping", "ecr"]
}

# Stack-specific config - hardcoded ARN for this bootstrap stack
globals {
  terraform_iam_role_arn = "arn:aws:iam::857059614049:role/ksk-gbl-ecr-bootstrap-admin"
}
