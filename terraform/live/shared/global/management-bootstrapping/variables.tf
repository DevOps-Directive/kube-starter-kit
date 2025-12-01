variable "terraform_iam_role_arn" {}

variable "aws_region" {
  default = "us-east-2"
}

variable "github_oidc_assume_role_arn" {}

variable "sso_admin_assume_role_arn" {}
