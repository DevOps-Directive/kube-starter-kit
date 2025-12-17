# Outputs for sharing with dependent stacks
output "terraform_iam_role_arn" {
  backend = "terraform"
  value   = module.account-bootstrapping.terraform_iam_role_arn
}
