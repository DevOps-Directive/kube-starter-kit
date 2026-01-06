# Terraform Infrastructure with Terramate

This directory contains the Terraform infrastructure for Kube Starter Kit, orchestrated with [Terramate](https://terramate.io/).

## Directory Structure

```
terraform/
├── config.tm.hcl           # Root globals (namespace, backend config, provider versions)
├── imports.tm.hcl          # Import mixins for all stacks
├── scripts.tm.hcl          # Terramate scripts for terraform orchestration
├── imports/
│   └── mixins/
│       ├── backend.tm.hcl  # Generates _backend.tf (S3 backend)
│       ├── provider.tm.hcl # Generates _provider.tf (AWS provider)
│       └── sharing.tm.hcl  # Configures outputs sharing backend
├── live/                   # Stack definitions by environment
│   ├── config.tm.hcl       # Live-specific globals
│   ├── shared/             # Cross-account resources (ECR, IAM Identity Center)
│   │   ├── global/         # Global (non-regional) resources
│   │   └── us-east-2/      # Regional resources
│   └── staging/            # Staging environment
│       ├── global/         # Account-level resources (bootstrapping)
│       └── us-east-2/      # Regional resources (networking, EKS, services)
├── modules/                # Reusable Terraform modules
└── bootstrap/              # Initial AWS account setup (manual)
```

## Prerequisites

- [mise](https://mise.jdx.dev/) - Tool version manager
- AWS credentials configured
- Terraform state bucket (created via bootstrap process)

Install tools:
```bash
cd terraform
mise install
```

## Quick Start

### List All Stacks

```bash
# List stacks in dependency order
terramate list --run-order

# Show dependency graph
terramate experimental run-graph
```

### Initialize Stacks

```bash
# Initialize all stacks
terramate run -- terraform init

# Initialize specific stack by tags
terramate run --tags staging:us-east-2:eks -- terraform init
```

### Plan Changes

```bash
# Plan all stacks (with outputs sharing and mocks for missing dependencies)
terramate script run terraform plan

# Plan specific environment
terramate script run --tags staging terraform plan

# Plan single stack
terramate script run --tags staging:us-east-2:networking terraform plan
```

### Apply Changes

```bash
# Apply all stacks in dependency order
terramate script run terraform apply

# Apply specific stack
terramate script run --tags staging:us-east-2:eks terraform apply
```

### Validate Configuration

```bash
# Validate all stacks
terramate run -- terraform validate
```

## Stack Types

### Module-Based Stacks

Most stacks use reusable modules from `modules/`. These have:
- `stack.tm.hcl` - Stack definition and tags
- `config.tm.hcl` - Stack-specific globals
- `main.tf.tmgen` - Template that generates `main.tf`
- `inputs.tm.hcl` - Cross-stack dependencies (outputs sharing)
- `outputs.tm.hcl` - Outputs to share with dependent stacks

Generated files (do not edit):
- `_backend.tf` - S3 backend configuration
- `_provider.tf` - AWS provider with assume_role
- `_sharing.tf` - Variables from inputs + output definitions
- `main.tf` - Module invocation (from `.tmgen`)

### Inline Stacks

Some stacks (especially in `shared/`) have inline Terraform instead of modules. These have:
- `stack.tm.hcl` with `global.stack.inline = true`
- Manual `main.tf`, `variables.tf`, etc.
- No generated `_provider.tf` (provider defined inline)

## Outputs Sharing

Terramate's outputs sharing enables cross-stack dependencies without `terraform_remote_state`.

### Defining Outputs

In `outputs.tm.hcl`:
```hcl
output "vpc_id" {
  backend = "terraform"
  value   = module.networking.vpc_id
}
```

### Consuming Outputs

In `inputs.tm.hcl`:
```hcl
input "vpc_id" {
  backend       = "terraform"
  from_stack_id = "staging-use2-networking"
  value         = outputs.vpc_id.value
  mock          = "vpc-mock12345"  # Used when dependency not yet applied
}
```

The input becomes a Terraform variable, used in `main.tf.tmgen`:
```hcl
module "eks" {
  vpc_id = var.vpc_id
  # ...
}
```

## Common Commands

| Command | Description |
|---------|-------------|
| `terramate list` | List all stacks |
| `terramate list --run-order` | List stacks in execution order |
| `terramate list --tags staging` | List stacks with specific tag |
| `terramate generate` | Regenerate all generated files |
| `terramate run -- CMD` | Run command in all stacks |
| `terramate script run terraform plan` | Run plan script with sharing |
| `terramate script run terraform apply` | Run apply script with sharing |

## Adding a New Stack

1. Create directory under `live/{stage}/{region}/`

2. Create `stack.tm.hcl`:
```hcl
stack {
  id          = "staging-use2-myservice"
  name        = "myservice"
  description = "My service infrastructure"
  tags        = ["staging", "us-east-2", "myservice"]

  # Optional: dependencies
  after = ["tag:staging:us-east-2:eks"]
}
```

3. Create `config.tm.hcl` for stack-specific globals

4. Create `main.tf.tmgen` for module invocation

5. Create `inputs.tm.hcl` if consuming outputs from other stacks

6. Create `outputs.tm.hcl` if exposing outputs to other stacks

7. Generate files:
```bash
terramate generate
```

## Bootstrapping New Accounts

See `bootstrap/README.md` for initial AWS account setup.

## CI/CD Integration

Terramate integrates with CI/CD via:
- Change detection: `terramate list --changed`
- Parallel execution: `terramate run -j 4 -- terraform plan`
- Terramate Cloud: Dashboard, drift detection, deployment tracking

## Troubleshooting

### "repository has untracked files"

Terramate requires a clean git state by default. Either:
- Stage your changes: `git add -A`
- Or disable safeguards: `terramate run --disable-safeguards=git-untracked -- CMD`

### Missing dependency outputs

When planning before dependencies are applied, use mocks:
```bash
terramate script run terraform plan  # Uses mock_on_fail
```

### Regenerate files after config changes

```bash
terramate generate
```

## Migration from Terragrunt

This project was migrated from Terragrunt. Key differences:
- `terragrunt.hcl` → `stack.tm.hcl` + `*.tm.hcl` files
- `dependency` blocks → `input` blocks (outputs sharing)
- `include` blocks → `import` blocks + mixins
- `generate` blocks → `generate_hcl` blocks in mixins
