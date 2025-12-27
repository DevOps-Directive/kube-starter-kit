variable "terraform_iam_role_arn" {}

variable "aws_region" {}

variable "github_oidc_assume_role_arn" {}

variable "sso_admin_assume_role_arn" {}

# Route53 zone configuration
variable "create_zone" {
  description = "Whether to create a Route53 hosted zone"
  type        = bool
  default     = false
}

variable "zone_name" {
  description = "Name of the Route53 hosted zone (e.g. staging.example.com)"
  type        = string
  default     = null
}

variable "zone_external_dns_owner" {
  description = "External-dns owner identifier for TXT record ownership. Set to null to skip creating the record."
  type        = string
  default     = null
}
