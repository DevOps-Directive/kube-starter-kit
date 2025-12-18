// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

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
