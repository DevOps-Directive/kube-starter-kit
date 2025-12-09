variable "aws_region" {
  default = "us-east-2"
}

variable "terraform_iam_role_arn" {}

variable "repository_read_access_arns" {
  description = "ARNs allowed read/pull access to the ECR repositories (e.g., account roots, roles)."
  type        = list(string)
}
