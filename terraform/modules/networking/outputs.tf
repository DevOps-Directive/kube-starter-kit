output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host (for SSM sessions)"
  value       = var.enable_bastion ? module.bastion[0].id : null
}
