variable "environment_name" {}

variable "aws_region" {}

variable "terraform_iam_role_arn" {}

variable "vpc_id" {}

variable "private_subnets" {
  type = list(string)
}
