// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

variable "aws_region" {
  default     = "us-east-2"
  description = "AWS region"
  type        = string
}
variable "repository_read_access_arns" {
  default = [
    "arn:aws:iam::038198578795:root",
    "arn:aws:iam::964263445142:root",
  ]
  description = "ARNs that have read access to ECR repositories"
  type        = list(string)
}
