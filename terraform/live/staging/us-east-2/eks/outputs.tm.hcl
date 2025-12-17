# Outputs for sharing with dependent stacks
output "eks_cluster_name" {
  backend = "terraform"
  value   = module.eks.eks_cluster_name
}

output "eks_cluster_endpoint" {
  backend = "terraform"
  value   = module.eks.eks_cluster_endpoint
}

output "deploy_key_public_key" {
  backend = "terraform"
  value   = module.eks.deploy_key_public_key
}

output "deploy_key_setup" {
  backend = "terraform"
  value   = module.eks.deploy_key_setup
}

output "karpenter_interruption_queue" {
  backend = "terraform"
  value   = module.eks.karpenter_interruption_queue
}

output "karpenter_node_role_name" {
  backend = "terraform"
  value   = module.eks.karpenter_node_role_name
}

output "argocd_webhook_setup" {
  backend = "terraform"
  value   = module.eks.argocd_webhook_setup
}
