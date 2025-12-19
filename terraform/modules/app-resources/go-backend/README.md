# go-backend Service Terraform Module

This module is an **example** demonstrating how to provision and configure access to resources outside of the Kubernetes cluster. It shows the pattern for giving pods secure access to AWS resources using EKS Pod Identity.

## Purpose

In a Kubernetes environment, applications often need to access external resources that are not managed by Kubernetes itself. This module demonstrates that pattern by:

1. **Provisioning an external resource** - In this case, an S3 bucket
2. **Creating an IAM policy** - Defining the permissions needed to access that resource
3. **Configuring Pod Identity** - Allowing pods to assume an IAM role with those permissions

## The Pattern

While this example uses S3, the same pattern applies to any Terraform-managed resource:

- **Databases**: RDS (PostgreSQL, MySQL), Aurora, PlanetScale, or any database with a Terraform provider
- **Message queues**: SQS, SNS, Amazon MQ
- **Caching**: ElastiCache (Redis, Memcached)
- **Storage**: S3, EFS, FSx
- **Other AWS services**: DynamoDB, Secrets Manager, Parameter Store
- **Third-party services**: Any service with a Terraform provider (PlanetScale, MongoDB Atlas, etc.)

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                     This Terraform Module                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Create Resource        2. Create IAM Policy             │
│     ┌──────────┐              ┌──────────────┐              │
│     │ S3 Bucket│              │ IAM Policy   │              │
│     │          │◄─────────────│ (S3 Access)  │              │
│     └──────────┘              └──────┬───────┘              │
│                                      │                      │
│                          3. Pod Identity Association        │
│                               ┌──────▼───────┐              │
│                               │   IAM Role   │              │
│                               │ + Association│              │
│                               └──────┬───────┘              │
│                                      │                      │
└──────────────────────────────────────┼──────────────────────┘
                                       │
                    ┌──────────────────▼──────────────────┐
                    │         EKS Cluster                 │
                    │  ┌────────────────────────────────┐ │
                    │  │ Pod (go-backend)               │ │
                    │  │  - namespace: go-backend-*     │ │
                    │  │  - serviceAccount: go-backend  │ │
                    │  │                                │ │
                    │  │  Gets AWS credentials          │ │
                    │  │  automatically via Pod Identity│ │
                    │  └────────────────────────────────┘ │
                    └─────────────────────────────────────┘
```

## Adapting for Other Resources

To adapt this pattern for a different resource (e.g., RDS database):

1. **Replace the resource definition** - Swap the S3 bucket module for your resource (e.g., `terraform-aws-modules/rds/aws`)
2. **Update the IAM policy** - Change the policy statements to match the permissions your application needs
3. **Keep the Pod Identity setup** - The Pod Identity configuration remains largely the same

### Example: RDS Database

```hcl
# Instead of S3 bucket, create an RDS instance
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  # ... RDS configuration
}

# Update IAM policy for RDS access (if needed for IAM auth)
resource "aws_iam_policy" "rds_access" {
  policy = jsonencode({
    Statement = [{
      Effect   = "Allow"
      Action   = ["rds-db:connect"]
      Resource = "arn:aws:rds-db:${var.region}:${var.account_id}:dbuser:${module.rds.db_instance_resource_id}/*"
    }]
  })
}

# Pod Identity remains the same pattern
module "pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  # ... same pattern as this module
}
```

## Usage

```hcl
module "go_backend" {
  source = "../../modules/services/go-backend"

  eks_cluster_name = "my-cluster"

  # Kubernetes configuration
  kubernetes_namespace       = "go-backend-kustomize"
  kubernetes_service_account = "go-backend"

  # S3 configuration
  bucket_versioning_enabled = true
  force_destroy            = false  # Set to true for non-production

  # Naming context (Cloud Posse null-label)
  namespace   = "myorg"
  environment = "staging"
  name        = "go-backend"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| eks_cluster_name | Name of the EKS cluster for pod identity association | `string` | n/a | yes |
| kubernetes_namespace | Kubernetes namespace where the service runs | `string` | `"go-backend-kustomize"` | no |
| kubernetes_service_account | Kubernetes service account name | `string` | `"go-backend"` | no |
| force_destroy | Force destroy S3 bucket on deletion | `bool` | `false` | no |
| bucket_versioning_enabled | Enable S3 bucket versioning | `bool` | `true` | no |

Plus all standard [Cloud Posse null-label](https://github.com/cloudposse/terraform-null-label) context variables.

## Outputs

| Name | Description |
|------|-------------|
| s3_bucket_id | The name of the S3 bucket |
| s3_bucket_arn | The ARN of the S3 bucket |
| s3_bucket_regional_domain_name | The regional domain name of the S3 bucket |
| iam_policy_arn | ARN of the IAM policy for S3 access |
| iam_role_arn | ARN of the IAM role for pod identity |
| iam_role_name | Name of the IAM role for pod identity |
| pod_identity_association_id | The ID of the EKS pod identity association |

## Why Pod Identity?

This module uses [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html) rather than IRSA (IAM Roles for Service Accounts) because:

- Simpler setup (no OIDC provider configuration needed)
- Credentials are managed by the EKS Pod Identity Agent
- Better security isolation between pods
- Easier credential rotation
