stack {
  id          = "shared-use2-ecr-repositories"
  name        = "ecr-repositories"
  description = "ECR repositories for container images"
  tags        = ["shared", "us-east-2", "ecr", "repositories"]

  # Depends on ecr-repositories-bootstrapping for IAM role
  after = ["tag:shared:global:ecr-repositories-bootstrapping"]
}

globals "stack" {
  inline = true # Stack has its own provider/terraform blocks in main.tf
}
