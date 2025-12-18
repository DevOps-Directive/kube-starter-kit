# Outputs sharing backend configuration
# This enables cross-stack dependency management via Terraform outputs
sharing_backend "terraform" {
  type     = terraform
  filename = "_shared.tf"
  command  = ["terraform", "output", "-json"]
}
