variable "aws_region" {}

variable "terraform_iam_role_arn" {}

variable "sso_admin_role_arn" {}

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

variable "eks_addon_versions" {
  description = "Pinned versions for EKS managed addons (addon_version strings)."
  type = object({
    coredns                = string
    eks_pod_identity_agent = string
    kube_proxy             = string
    vpc_cni                = string
    aws_ebs_csi_driver     = string
  })

  default = {
    coredns                = "v1.12.4-eksbuild.1"
    eks_pod_identity_agent = "v1.3.10-eksbuild.1"
    kube_proxy             = "v1.33.5-eksbuild.2"
    vpc_cni                = "v1.20.5-eksbuild.1"
    aws_ebs_csi_driver     = "v1.53.0-eksbuild.1"
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

variable "github_repository" {
  description = "GitHub repository name for webhook configuration"
  type        = string
  default     = "kube-starter-kit"
}

variable "create_github_webhook" {
  description = "Whether to create the GitHub webhook for ArgoCD. Set to false if using octo-sts (no webhook permissions)."
  type        = bool
  default     = false
}
