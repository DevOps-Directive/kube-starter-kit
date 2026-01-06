stack {
  id          = "shared-gbl-terraform-bootstrapping"
  name        = "terraform-bootstrapping"
  description = "Bootstrap Terraform state bucket and infrastructure account IAM"
  tags        = ["shared", "global", "bootstrapping", "infra"]
}

# This stack doesn't use a provider with assume_role - it runs with direct credentials
# The provider is defined inline in main.tf
globals {
  # Unset to prevent provider generation (inline provider in main.tf)
  terraform_iam_role_arn = unset
}

globals "stack" {
  inline = true # Stack has its own provider/terraform blocks in main.tf
}
