# Outputs sharing backend configuration
# This enables cross-stack dependency management via Terraform outputs
sharing_backend "terraform" {
  type = terraform
  # NOTE: This filename gets used for BOTH shared outputs and the variables that consume them
  filename = "_shared.tf"
  command  = ["terraform", "output", "-json"]
}
