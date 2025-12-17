# Outputs for sharing with dependent stacks
output "eks_cluster_name" {
  backend = "terraform"
  value   = module.eks.eks_cluster_name
}

output "eks_cluster_endpoint" {
  backend = "terraform"
  value   = module.eks.eks_cluster_endpoint
}
