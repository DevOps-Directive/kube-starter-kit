# Input from management-bootstrapping stack
input "terraform_iam_role_arn" {
  backend       = "terraform"
  from_stack_id = "shared-gbl-management-bootstrapping"
  value         = outputs.terraform_iam_role_arn.value
  mock          = "arn:aws:iam::000000000000:role/mock-bootstrap-admin"
}
