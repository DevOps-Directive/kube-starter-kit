output "deploy_key_public_key" {
  value = tls_private_key.deploy_key.public_key_openssh
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "karpenter_interruption_queue" {
  value = module.karpenter.queue_name
}
