variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

# Note: terraform_iam_role_arn is generated in _variables.tf via Terramate globals
