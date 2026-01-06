stack {
  id          = "shared-gbl-management-bootstrapping"
  name        = "management-bootstrapping"
  description = "Bootstrap IAM for management account (IAM Identity Center)"
  tags        = ["shared", "global", "bootstrapping", "management"]
}

# Stack-specific config - hardcoded ARN for this bootstrap stack
globals {
  terraform_iam_role_arn = "arn:aws:iam::085164809580:role/ksk-gbl-mgmt-bootstrap-admin"
}
