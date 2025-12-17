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
