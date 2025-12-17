# Outputs for sharing with dependent stacks
output "s3_bucket_id" {
  backend = "terraform"
  value   = module.go_backend.s3_bucket_id
}

output "s3_bucket_arn" {
  backend = "terraform"
  value   = module.go_backend.s3_bucket_arn
}

output "s3_bucket_regional_domain_name" {
  backend = "terraform"
  value   = module.go_backend.s3_bucket_regional_domain_name
}

output "iam_policy_arn" {
  backend = "terraform"
  value   = module.go_backend.iam_policy_arn
}

output "iam_role_arn" {
  backend = "terraform"
  value   = module.go_backend.iam_role_arn
}

output "iam_role_name" {
  backend = "terraform"
  value   = module.go_backend.iam_role_name
}

output "pod_identity_association_id" {
  backend = "terraform"
  value   = module.go_backend.pod_identity_association_id
}
