# AGENTS.md - Kube Starter Kit

Instructions for AI coding agents working in this repository.

## Quick Reference

```bash
mise install                    # Install tools for current directory
mise tasks                      # List context-aware tasks
mise task ls --all              # List all tasks across monorepo
```

## Build/Lint/Test Commands

### Terraform/Terramate

```bash
# Formatting (CI enforced)
terramate fmt --check                      # Check Terramate formatting
terraform fmt -recursive -check -diff      # Check Terraform formatting

# Stack operations
terramate list                             # List all stacks
terramate list --changed                   # List changed stacks
terramate run -- terraform init            # Initialize all stacks
terramate script run preview               # Plan with outputs sharing
terramate script run apply                 # Apply with outputs sharing
```

### Kubernetes Manifests

```bash
# From kubernetes/src/infrastructure/, services/, or argocd/ directories
mise run render-all staging                # Render all manifests for staging
mise run render-all production             # Render for production

# From individual component directory (e.g., kubernetes/src/services/go-backend/)
mise run render-cluster staging            # Render single component
```

### Local Development (`local/`)

```bash
mise run create-cluster                    # Create KinD cluster
mise run delete-cluster                    # Delete KinD cluster
mise run cloud-provider-kind               # Start cloud provider (requires sudo)
mise run tilt-up                           # Start Tilt for local dev
```

### Documentation (`docs/`)

```bash
mise run dev                               # Start Mintlify dev server
```

## Code Style Guidelines

### Terraform/Terramate

- **Formatting**: `terraform fmt` and `terramate fmt` are CI-enforced
- **Module structure**: `main.tf`, `variables.tf`, `outputs.tf`, `context.tf`
- **Naming**: Use snake_case for resources, variables, and outputs
- **Locals**: Define computed values in `locals {}` blocks
- **Comments**: Use `# TODO:` for future work, document non-obvious decisions

### Docker

- **Multi-stage builds**: Separate build and runtime stages
- **Non-root user**: Create `appuser` with UID 10001
- **Static binaries**: Use `CGO_ENABLED=0` for Go
- **Cache mounts**: Use BuildKit cache for faster builds

```dockerfile
RUN --mount=type=cache,target=/go/pkg/mod/ \
    CGO_ENABLED=0 go build -o /bin/server ./cmd
```

### Kubernetes Manifests

- Three templating approaches demonstrated: Kustomize, Helm, Timoni
- All render to `kubernetes/rendered/{environment}/`
- CI validates rendered manifests match source (`gitops-check-rendered-manifests.yml`)

### Documentation (MDX)

- **Frontmatter**: Required `title` and `description` fields
- **Voice**: Second-person ("you")
- **Code blocks**: Always include language tags
- **Links**: Use relative paths for internal links
- **Punctuation**: Never use em-dash ("---"), prefer commas/colons/semicolons

## Architecture Patterns

- **GitOps**: ArgoCD app-of-apps pattern; source in `kubernetes/src/`, rendered in `kubernetes/rendered/`
- **AWS**: Pod identity (not IRSA); External Secrets with AWS Secrets Manager/SSM
- **Migrations**: Atlas for schema migrations, run as K8s Jobs with Argo CD sync waves

## Git Workflow

- Never use `--no-verify` when committing
- Never skip or disable pre-commit hooks
- Include rendered manifests in commits (CI validates they're current)

## Directory-Specific Notes

| Directory | Purpose |
|-----------|---------|
| `terraform/live/` | Environment configs (`*.tm.hcl` stacks) |
| `terraform/modules/` | Reusable modules (`main.tf`, `variables.tf`, `outputs.tf`) |
| `kubernetes/src/` | Source manifests (Kustomize/Helm/Timoni templates) |
| `kubernetes/rendered/` | Generated manifests (GitOps deployment source) |
| `services/` | Demo application code (not the focus of this repo) |
| `local/` | Dev environment (KinD + Tilt configuration) |
| `docs/` | Mintlify docs (MDX files with `docs.json` config) |

## Common Mistakes to Avoid

1. **Forgetting to render manifests** after editing `kubernetes/src/`
2. **Running terraform directly** instead of via `terramate script run`
3. **Hardcoding secrets** - use External Secrets with AWS SSM/Secrets Manager
4. **Using IRSA** - this project uses Pod Identity instead

## Tool Versions (from mise.toml)

Terraform 1.x (CI: 1.14.3), Terramate 0.15.x, Go 1.25.3, kubectl 1.34, Helm 3.x, Kustomize 5.8, ArgoCD 3.2, Timoni 0.25.x
