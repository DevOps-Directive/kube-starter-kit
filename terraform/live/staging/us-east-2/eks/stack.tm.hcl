stack {
  id          = "staging-use2-eks"
  name        = "eks"
  description = "EKS cluster for staging us-east-2"
  tags        = ["staging", "us-east-2", "eks", "infrastructure"]

  # Depends on networking and bootstrapping
  after = [
    "tag:staging:us-east-2:networking",
    "tag:staging:global:bootstrapping",
  ]
}

# Enable random provider for this stack
globals "terraform" "providers" "random" {
  enabled = true
}
