# Terraform Bootstrap

This directory contains scripts and templates for bootstrapping Terraform infrastructure in AWS.

## Prerequisites

- AWS CLI configured with appropriate credentials
- [mise](https://mise.jdx.dev/) installed for running tasks
- `jq` for JSON processing

## Bootstrapping Steps

### 1. Create S3 State Bucket

Create an S3 bucket to store Terraform state:

```bash
mise run create-state-bucket --bucket-name <your-bucket-name> --aws-region <region>
```

**Example:**
```bash
mise run create-state-bucket --bucket-name my-terraform-state --aws-region us-east-2
```

### 2. Get SSO Role ARN

Retrieve the ARN of your current AWS SSO role (used as the trusted principal):

```bash
mise run get-sso-role-arn
```

### 3. Create IAM Role in Target Account

Create an IAM role in the target account that can be assumed by the infrastructure SSO role:

```bash
mise run create-terraform-iam-role-in-target-account \
  --role-name <role-name> \
  --infra-sso-role-arn <arn-from-step-2>
```

This creates an IAM role with `AdministratorAccess` that trusts the specified SSO role.

## Files

- `mise.toml` - Task definitions for bootstrapping commands
- `trust-policy.json.TEMPLATE` - IAM trust policy template for cross-account access