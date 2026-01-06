output "terraform_iam_role_arn" {
  value = module.iam_role.arn
}

output "zone_name_servers" {
  description = "Name servers for the Route53 zone"
  value       = var.create_zone ? module.zone[0].name_servers : null
}

output "zone_arn" {
  description = "ARN of the Route53 zone"
  value       = var.create_zone ? module.zone[0].arn : null
}
