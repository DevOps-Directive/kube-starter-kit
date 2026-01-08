variable "aws_region" {}

variable "terraform_iam_role_arn" {}

# REMOVED: sso_admin_role_arn - was unused, admin_sso_role_arn is the correct variable

variable "vpc_id" {}

variable "private_subnets" {
  type = list(string)
}

variable "route53_zone_arn" {}

variable "kubernetes_version" {
  type    = string
  default = "1.33"
}

variable "base_node_group_kubernetes_version" {
  description = "Kubernetes version for the base managed node group. Can lag the control plane."
  type        = string
  default     = "1.33"
}

variable "base_node_group_instance_types" {
  description = "Instance types for the base EKS managed node group."
  type        = list(string)
  default     = ["t3.large"]
}

# Optional (since you also have a TODO on this)
variable "base_node_group_ami_type" {
  description = "AMI type for the base EKS managed node group."
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "base_node_group_ami_release_version" {
  description = "AMI release version for the base EKS managed node group. Defaults to latest AMI release version for the given Kubernetes version and AMI type. Pin this to avoid unexpected node group upgrades when modifying other resources."
  type        = string
  default     = null
}

variable "eks_addon_versions" {
  description = "Override versions for EKS managed addons. Partial overrides are supported - only specify the addons you want to change."
  type = object({
    coredns                = optional(string)
    eks_pod_identity_agent = optional(string)
    kube_proxy             = optional(string)
    vpc_cni                = optional(string)
    aws_ebs_csi_driver     = optional(string)
  })
  default = {}
}

locals {
  # Default addon versions - update these when upgrading
  eks_addon_version_defaults = {
    coredns                = "v1.12.4-eksbuild.1"
    eks_pod_identity_agent = "v1.3.10-eksbuild.1"
    kube_proxy             = "v1.33.5-eksbuild.2"
    vpc_cni                = "v1.20.5-eksbuild.1"
    aws_ebs_csi_driver     = "v1.53.0-eksbuild.1"
  }

  # Merge overrides with defaults (overrides take precedence)
  eks_addon_versions = {
    for k, v in local.eks_addon_version_defaults :
    k => coalesce(try(var.eks_addon_versions[k], null), v)
  }
}

variable "admin_sso_role_arn" {
  type    = string
  default = "arn:aws:iam::038198578795:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_47aa578228eb79ff"
}

variable "argocd_hostname" {
  description = "Hostname for ArgoCD server (used for webhook URL)"
  type        = string
}

variable "endpoint_public_access" {
  description = "Whether the EKS cluster API endpoint is publicly accessible. Set to false for private-only access (requires bastion/VPN)."
  type        = bool
  default     = false
}

variable "endpoint_private_access" {
  description = "Whether the EKS cluster API endpoint is accessible from within the VPC."
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "VPC CIDR block (used for private endpoint security group rules)"
  type        = string
  default     = null
}

variable "github_repository" {
  description = "GitHub repository name for webhook configuration"
  type        = string
  default     = "kube-starter-kit"
}
