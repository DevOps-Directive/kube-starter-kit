# Example Environment Configurations

This directory contains example Terragrunt configurations for additional environments that are **not actively deployed**. They serve as reference implementations for:

- **Multi-region deployments** (e.g., `staging/us-east-1/`)
- **Production environments** (e.g., `prod/us-east-2/`)

## Structure

```
examples/
├── prod/                    # Production account example
│   └── us-east-2/
│       ├── networking/      # VPC, subnets, NAT
│       └── eks/             # EKS cluster
└── staging/                 # Secondary region example
    └── us-east-1/
        ├── networking/
        └── eks/
```

## Usage

To deploy one of these examples:

1. **Copy** the desired configuration to `terraform/live/`
2. **Update** the `stage.hcl` with your AWS account ID and IAM role ARNs
3. **Update** the `environment.hcl` with the correct region settings
4. **Bootstrap** the AWS account if needed (see `terraform/bootstrap/`)
5. **Deploy** using Terragrunt:
   ```bash
   cd terraform/live/<env>/<region>/networking
   terragrunt plan
   terragrunt apply
   ```

## Why These Are Examples

These configurations demonstrate that the Terraform modules support:
- Multiple AWS accounts (prod vs staging)
- Multiple regions (us-east-1, us-east-2)
- Consistent naming via CloudPosse label module (`ksk-{region}-{stage}-{component}`)

They were used to validate the module design but are not actively maintained or deployed by CI/CD.

## Prerequisites for Production

Before deploying the production example:

1. Create a separate AWS account for production
2. Run the bootstrap process:
   ```bash
   cd terraform/bootstrap
   mise run get-sso-role-arn
   mise run create-terraform-iam-role-in-target-account \
     --role-name ksk-gbl-prod-bootstrap-admin \
     --infra-sso-role-arn <arn>
   ```
3. Update `prod/stage.hcl` with actual ARNs
