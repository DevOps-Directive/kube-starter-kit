# Stack-specific configuration
globals "ecr" {
  repository_read_access_arns = [
    "arn:aws:iam::038198578795:root", # Staging
    "arn:aws:iam::964263445142:root", # Production
  ]
}
