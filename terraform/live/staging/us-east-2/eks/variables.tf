variable "aws_region" {}

variable "terraform_iam_role_arn" {}

variable "sso_admin_role_arn" {}

variable "route53_zone_arn" {}

variable "vpc_id" {}

variable "private_subnets" {
  type = list(string)
}

