output "zone_name_servers" {
  value = module.zone.name_servers
}

output "zone_arn" {
  value = module.zone.arn
}

output "terraform_iam_role_arn" {
  value = module.account-bootstrapping.terraform_iam_role_arn
}
