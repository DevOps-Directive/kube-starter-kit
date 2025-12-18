stack {
  id          = "example-staging-use1-eks"
  name        = "eks"
  description = "EKS cluster for staging us-east-1 (example)"
  tags        = ["staging", "us-east-1", "eks", "infrastructure", "example"]
  after = [
    "/terraform/live/staging/us-east-1/networking",
  ]
}
