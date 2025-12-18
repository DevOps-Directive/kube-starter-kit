stack {
  id          = "staging-use2-services-go-backend"
  name        = "go-backend"
  description = "Go backend service infrastructure (S3 bucket, IAM)"
  tags        = ["staging", "us-east-2", "services", "go-backend"]

  # Depends on EKS for cluster name
  after = ["tag:staging:us-east-2:eks"]
}
