variable "aws_region" {
  default = "us-east-2"
}

variable "terraform_iam_role_arn" {}

variable "vpc_id" {} # "vpc-0955989470c913b10"
variable "private_subnets" {
  type = list(string)
} # ["subnet-010a63eb87d2020b1", "subnet-047960b613aba7131", "subnet-02cd6c1bf461263c6"]

