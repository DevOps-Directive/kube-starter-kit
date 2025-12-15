# S3 bucket outputs
output "s3_bucket_id" {
  description = "The name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_bucket_regional_domain_name
}

# IAM outputs
output "iam_policy_arn" {
  description = "ARN of the IAM policy for S3 access"
  value       = aws_iam_policy.s3_access.arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role for pod identity"
  value       = module.pod_identity.iam_role_arn
}

output "iam_role_name" {
  description = "Name of the IAM role for pod identity"
  value       = module.pod_identity.iam_role_name
}

# Pod identity outputs
output "pod_identity_association_id" {
  description = "The ID of the EKS pod identity association"
  value       = module.pod_identity.associations
}
