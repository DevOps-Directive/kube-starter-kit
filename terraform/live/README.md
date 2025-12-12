# Live Terraform Configurations

This directory contains the **actively deployed** Terragrunt configurations for the Kube Starter Kit infrastructure.

## Structure

```
live/
├── root.hcl                 # Shared Terragrunt config (backend, common inputs)
├── shared/                  # Shared AWS account (ECR, state bucket, IAM)
│   ├── stage.hcl
│   ├── global/              # Account-wide resources
│   └── us-east-2/           # Regional resources (ECR repos)
└── staging/                 # Staging AWS account
    ├── stage.hcl
    ├── global/              # Account-wide resources (Route53, IAM)
    └── us-east-2/           # Regional resources
        ├── networking/      # VPC, subnets, NAT gateways
        └── eks/             # EKS cluster, Karpenter, add-ons
```

## Environments

| Directory | AWS Account | Purpose |
|-----------|-------------|---------|
| `shared/` | Infrastructure | ECR repositories, Terraform state, cross-account IAM |
| `staging/` | Staging | Development/staging EKS cluster and networking |

## Deployment

Deployments are managed by [Digger](https://digger.dev/) via CI/CD. On pull request:
- `digger plan` runs automatically
- `digger apply` runs on merge to main

### Manual Deployment

```bash
cd terraform/live/staging/us-east-2/networking
terragrunt plan
terragrunt apply
```

## Adding New Environments

For examples of multi-region or production configurations, see:
- [`terraform/examples/`](../examples/) - Reference implementations for additional regions/accounts

## Naming Convention

Resources follow the CloudPosse label pattern:
```
{namespace}-{environment}-{stage}-{component}
    ksk    -    use2     - staging -   eks
```
