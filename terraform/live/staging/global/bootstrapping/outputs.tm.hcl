# Outputs for sharing with dependent stacks
output "zone_arn" {
  backend = "terraform"
  value   = module.bootstrapping.zone_arn
}

output "zone_name_servers" {
  backend = "terraform"
  value   = module.bootstrapping.zone_name_servers
}
