variable "environment_name" {}

variable "aws_region" {}

variable "terraform_iam_role_arn" {}

variable "nat_mode" {
  validation {
    condition     = contains(["fck_nat", "single_nat_gateway", "one_nat_gateway_per_az"], var.nat_mode)
    error_message = "Allowed values for nat_mode are \"fck_nat\", \"single_nat_gateway\", or \"one_nat_gateway_per_az\"."
  }
}
