variable "environment_name" {}

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
  # default   = "10.0.0.0/16" no default to ensur explicit choice of CIDRs (to avoid overlap)
}

variable "planetscale_endpoint_service_name" {
  type = string
  # TODO: remove default
  default = "com.amazonaws.vpce.us-east-2.vpce-svc-069f88c102c1a7fba" # us-east-2 endpoint retrieved from https://planetscale.com/docs/vitess/connecting/private-connections
}

variable "fck-nat_instance_type" {
  type    = string
  default = "t4g.nano" # TODO: test to see if this becomes limiting (default for this is t4g.micro...)
}

# Bastion host configuration
variable "enable_bastion" {
  description = "Whether to create a bastion host for private resource access via SSM"
  type        = bool
  default     = false
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host (must be ARM64/Graviton)"
  type        = string
  default     = "t4g.nano"
}
