stack {
  id          = "shared-gbl-user-management"
  name        = "user-management"
  description = "IAM Identity Center users and permission sets"
  tags        = ["shared", "global", "user-management", "iam"]

  # Depends on management-bootstrapping for IAM role
  after = ["tag:shared:global:management-bootstrapping"]
}

globals "stack" {
  inline = true # Stack has its own provider/terraform blocks in main.tf
}
