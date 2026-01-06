# Stack-specific configuration
globals "eks" {
  kubernetes_version                 = "1.34"
  base_node_group_kubernetes_version = "1.34"
  endpoint_public_access             = false
  endpoint_private_access            = true
  argocd_hostname                    = "argocd.prod.kubestarterkit.com"
}
