# Example Environment Configurations

This directory contains example Terramate configurations for additional environments that are **not actively deployed**. They serve as reference implementations for:

- **Multi-region deployments** (e.g., `staging/us-east-1/`)
- **Production environments** (e.g., `prod/us-east-2/`)

## Structure

```
examples/
├── prod/                           # Production account example
│   ├── config.tm.hcl               # Stage globals (IAM roles, stage name)
│   ├── global/
│   │   ├── config.tm.hcl           # Global environment config
│   │   └── bootstrapping/          # Account bootstrapping (Route53, IAM)
│   │       ├── stack.tm.hcl
│   │       └── config.tm.hcl
│   └── us-east-2/
│       ├── config.tm.hcl           # Region environment config
│       ├── networking/             # VPC, subnets, NAT
│       │   ├── stack.tm.hcl
│       │   └── config.tm.hcl
│       └── eks/                    # EKS cluster
│           ├── stack.tm.hcl
│           ├── config.tm.hcl
│           └── inputs.tm.hcl       # Cross-stack dependencies
└── staging/                        # Secondary region example
    ├── config.tm.hcl
    └── us-east-1/
        ├── config.tm.hcl
        ├── networking/
        └── eks/
```

## Usage

To deploy one of these examples:

1. **Copy** the desired stack directories to `terraform/live/`
2. **Update** the `config.tm.hcl` files with your AWS account ID and IAM role ARNs
3. **Update** stack IDs in `stack.tm.hcl` and `inputs.tm.hcl` to match your naming
4. **Bootstrap** the AWS account if needed (see `terraform/bootstrap/`)
5. **Generate** Terraform code and **deploy** using Terramate:
   ```bash
   cd terraform
   mise exec -- terramate generate
   mise exec -- terramate run --tags 'prod' -- terraform init
   mise exec -- terramate run --tags 'prod' --enable-sharing -- terraform plan
   ```

## Key Files

- **`stack.tm.hcl`** - Defines the stack (id, name, tags, dependencies)
- **`config.tm.hcl`** - Stack-specific globals that configure the module
- **`inputs.tm.hcl`** - Cross-stack input dependencies (outputs sharing)

Generated files (created by `terramate generate`):
- **`_main.tf`** - Module call
- **`_backend.tf`** - S3 backend configuration
- **`_provider.tf`** - AWS provider configuration
- **`_outputs.tm.hcl`** - Terramate output definitions
- **`_sharing.tf`** - Terraform outputs for sharing

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
3. Update `prod/config.tm.hcl` with actual ARNs
