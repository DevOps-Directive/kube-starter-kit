stack {
  id          = "example-prod-use2-eks"
  name        = "eks"
  description = "EKS cluster for production us-east-2 (example)"
  tags        = ["prod", "us-east-2", "eks", "infrastructure", "example"]
  after = [
    "/terraform/live/prod/us-east-2/networking",
    "/terraform/live/prod/global/bootstrapping",
  ]
}
