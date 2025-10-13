output "deploy_key_public_key" {
  value = module.eks-wrapper.deploy_key_public_key
}

output "eks_cluster_name" {
  value = module.eks-wrapper.eks_cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks-wrapper.eks_cluster_endpoint
}

output "karpenter_interruption_queue" {
  value = module.eks-wrapper.karpenter_interruption_queue
}
