# Outputs for sharing with dependent stacks
# Generated from: modules/networking/outputs.tf

output "vpc_id" {
  backend = "terraform"
  value   = module.networking.vpc_id
}

output "vpc_cidr" {
  backend = "terraform"
  value   = module.networking.vpc_cidr
}

output "private_subnets" {
  backend = "terraform"
  value   = module.networking.private_subnets
}

output "public_subnets" {
  backend = "terraform"
  value   = module.networking.public_subnets
}

output "bastion_instance_id" {
  backend = "terraform"
  value   = module.networking.bastion_instance_id
}

