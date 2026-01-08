# Stack-specific configuration
globals "eks" {
  kubernetes_version                 = "1.34"
  base_node_group_kubernetes_version = "1.34"
  endpoint_public_access             = false
  endpoint_private_access            = true
  argocd_hostname                    = "argocd.staging.kubestarterkit.com"

  # EKS addon version overrides (merged with module defaults)
  # Only specify addons you want to upgrade
  eks_addon_versions = {
    aws_ebs_csi_driver     = "v1.54.0-eksbuild.1"
    eks_pod_identity_agent = "v1.3.10-eksbuild.2"
    kube_proxy             = "v1.34.1-eksbuild.2"
    vpc_cni                = "v1.21.1-eksbuild.1"
  }
}
