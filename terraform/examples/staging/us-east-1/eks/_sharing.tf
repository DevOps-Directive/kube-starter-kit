// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

variable "vpc_id" {
  type = any
}
variable "vpc_cidr" {
  type = any
}
variable "private_subnets" {
  type = any
}
variable "route53_zone_arn" {
  type = any
}
output "eks_cluster_name" {
  value = module.eks.eks_cluster_name
}
output "eks_cluster_endpoint" {
  value = module.eks.eks_cluster_endpoint
}
output "deploy_key_public_key" {
  value = module.eks.deploy_key_public_key
}
output "deploy_key_setup" {
  value = module.eks.deploy_key_setup
}
output "karpenter_interruption_queue" {
  value = module.eks.karpenter_interruption_queue
}
output "karpenter_node_role_name" {
  value = module.eks.karpenter_node_role_name
}
output "argocd_webhook_setup" {
  value = module.eks.argocd_webhook_setup
}
