# S3 Bucket for go-backend service
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket        = "${module.this.id}-data"
  force_destroy = var.force_destroy

  versioning = {
    enabled = var.bucket_versioning_enabled
  }

  tags = module.this.tags
}

# IAM policy for S3 bucket access
resource "aws_iam_policy" "s3_access" {
  name        = "${module.this.id}-s3-access"
  description = "IAM policy for go-backend service to access its S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = module.s3_bucket.s3_bucket_arn
      },
      {
        Sid    = "ObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${module.s3_bucket.s3_bucket_arn}/*"
      }
    ]
  })

  tags = module.this.tags
}

# Pod Identity for go-backend service
module "pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.0.0"

  name = "${var.eks_cluster_name}-go-backend"

  additional_policy_arns = {
    S3Access = aws_iam_policy.s3_access.arn
  }

  association_defaults = {
    namespace       = var.kubernetes_namespace
    service_account = var.kubernetes_service_account
  }

  associations = {
    this = {
      cluster_name = var.eks_cluster_name
    }
  }

  tags = module.this.tags
}
