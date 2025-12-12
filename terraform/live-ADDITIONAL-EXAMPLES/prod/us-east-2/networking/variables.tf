variable "aws_region" {}

variable "terraform_iam_role_arn" {}

variable "nat_mode" {
  validation {
    condition     = contains(["fck_nat", "single_nat_gateway", "one_nat_gateway_per_az"], var.nat_mode)
    error_message = "Allowed values for nat_mode are \"fck_nat\", \"single_nat_gateway\", or \"one_nat_gateway_per_az\"."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "planetscale_endpoint_service_name" {
  description = "PlanetScale VPC endpoint service name for the region"
  type        = string
  default     = null
}
