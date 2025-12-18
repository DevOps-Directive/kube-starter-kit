// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

variable "terraform_iam_role_arn" {
  default     = "arn:aws:iam::085164809580:role/ksk-gbl-mgmt-bootstrap-admin"
  description = "IAM role ARN for Terraform to assume"
  type        = string
}
variable "aws_region" {
  default     = "us-east-2"
  description = "AWS region"
  type        = string
}
variable "github_oidc_assume_role_arn" {
  default     = "arn:aws:iam::094905625236:role/ksk-gbl-infra-bootstrap-github-oidc"
  description = "GitHub OIDC role ARN for CI/CD"
  type        = string
}
variable "sso_admin_assume_role_arn" {
  default     = "arn:aws:iam::094905625236:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_80ecc41059967962"
  description = "SSO admin role ARN"
  type        = string
}
