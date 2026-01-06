stack {
  id          = "shared-gbl-user-management"
  name        = "user-management"
  description = "IAM Identity Center users and permission sets"
  tags        = ["shared", "global", "user-management", "iam"]

  # Depends on management-bootstrapping for IAM role
  after = ["tag:shared:global:management-bootstrapping"]
}

# Stack-specific config - uses same IAM role as management-bootstrapping (same account)
globals {
  terraform_iam_role_arn = "arn:aws:iam::085164809580:role/ksk-gbl-mgmt-bootstrap-admin"
}

globals "stack" {
  inline = true # Stack has its own provider/terraform blocks in main.tf
}
