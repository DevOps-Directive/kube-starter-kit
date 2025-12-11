# CLAUDE.md - Kube Starter Kit

## Project Overview

Kube Starter Kit is a production-ready Kubernetes platform starter for AWS EKS environments. It provides infrastructure-as-code, GitOps deployments, CI/CD pipelines, and example applications designed for early-stage engineering teams to bootstrap a complete Kubernetes platform.

## Quick Start

**Prerequisites**: Run `mise install` from any directory to install required tools for that context.

```bash
# From project root - installs global tools
mise install

# From a service directory - installs service-specific tools
cd services/go-backend && mise install

# List available tasks
mise tasks
```

## Tech Stack

| Category | Tools |
|----------|-------|
| **Container Orchestration** | Kubernetes (EKS), KinD (local) |
| **Infrastructure** | Terraform, Terragrunt, OpenTofu |
| **GitOps** | ArgoCD (app-of-apps pattern) |
| **K8s Templating** | Kustomize, Helm, Timoni |
| **Deployment** | Kluctl (multi-env) |
| **Local Dev** | Tilt, Docker Compose |
| **Observability** | OpenTelemetry, SignOz |
| **Databases** | CloudNative-PG, Atlas (migrations) |
| **CI/CD** | GitHub Actions, Digger (Terraform) |
| **Tool Management** | mise (with monorepo support) |

## Directory Structure

```
kube-starter-kit/
├── .github/workflows/      # CI/CD pipelines (build, deploy, drift detection)
├── docs/                   # Mintlify documentation site
├── kubernetes/
│   ├── src/               # Source manifests (templates)
│   │   ├── argocd/        # ArgoCD app-of-apps definitions
│   │   ├── infrastructure/ # Cluster components (cert-manager, ingress, etc.)
│   │   └── services/      # Application deployments (3 approaches shown)
│   └── rendered/          # Generated manifests by environment
├── local/
│   ├── kind/              # KinD cluster config + registry script
│   └── tilt/              # Tiltfile for local dev
├── services/              # Application source code (Go backends)
├── terraform/
│   ├── bootstrap/         # Initial AWS account setup
│   ├── modules/           # Reusable modules (eks, networking, etc.)
│   └── live/              # Environment-specific configs (staging, etc.)
├── tools/                 # Shared mise tasks
├── mise.toml              # Root tool configuration
└── digger.yml             # Terraform CI/CD config
```

## Key Patterns

### Mise Task Organization

Tasks are hierarchical across the monorepo:
- **Root tasks**: Global utilities (`mise run //tools:generate-version`)
- **Directory tasks**: Context-specific (run `mise tasks` in any dir)

Common task locations:
- `/tools/` - Version tagging, manifest rendering, Git workflows
- `/kubernetes/` - Karpenter scaling, manifest rendering
- `/local/` - KinD cluster management, Tilt
- `/services/*/` - Docker builds, database, service-specific

### Kubernetes Deployment Approaches

Three equivalent approaches demonstrated with `go-backend`:

1. **Kustomize** - `kubernetes/src/services/go-backend/`
2. **Helm** - `kubernetes/src/services/go-backend-helm/`
3. **Timoni** - `kubernetes/src/services/go-backend-timoni/`

All render to `kubernetes/rendered/{environment}/`

### Infrastructure Components

Located in `kubernetes/src/infrastructure/`:
- **argocd** - GitOps controller
- **cert-manager** - TLS certificates
- **cloudnative-pg** - PostgreSQL operator
- **envoy-gateway** - API gateway
- **external-dns** - DNS automation
- **external-secrets** - AWS Secrets Manager integration
- **ingress-nginx** - Ingress controller
- **karpenter** - Autoscaling
- **reloader** - ConfigMap/Secret reload
- **signoz-k8s-infra** - Observability

## Common Commands

```bash
# Local development
cd local && mise run kind:create    # Create KinD cluster
cd local && mise run tilt:up        # Start Tilt

# Kubernetes manifests
cd kubernetes && mise run render    # Render manifests for all envs

# Services
cd services/go-backend && mise run docker:build
cd services/go-backend && mise run postgres:start
cd services/go-backend && mise run serve

# Terraform
cd terraform/live/staging && terragrunt plan
cd terraform/live/staging && terragrunt apply
```

## CI/CD Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `build-push.yml` | Push to main, tags | Build & push images to ECR |
| `check-rendered-manifests.yml` | PRs | Verify manifests are up-to-date |
| `digger-workflow.yml` | Digger | Terraform plan/apply |
| `update-gitops-manifests.yml` | Dispatch | Update image tags in manifests |
| `release-please.yml` | Push to main | Automated release PRs |

## Key Files

| File | Purpose |
|------|---------|
| `mise.toml` | Root tool versions and global tasks |
| `digger.yml` | Terraform CI/CD configuration |
| `kubernetes/src/argocd/` | ArgoCD app-of-apps definitions |
| `terraform/modules/eks/` | EKS cluster module |
| `.github/utils/file-filters.yaml` | CI path-based build triggers |

## Development Workflow

1. **Local testing**: Use KinD + Tilt (`local/` directory)
2. **Make changes**: Edit source in `kubernetes/src/` or `services/`
3. **Render manifests**: Run `mise run render` in `kubernetes/`
4. **Commit**: Include rendered manifests (CI validates they're current)
5. **PR**: CI runs manifest checks and Terraform plans
6. **Merge**: ArgoCD syncs changes to staging automatically

## Environment Structure

- **staging**: Primary development/testing environment
- **production**: Triggered via manual workflow dispatch or git tags

Terraform environments: `terraform/live/{staging,production}/`
K8s manifests: `kubernetes/rendered/{staging,production}/`

## Notes

- ArgoCD uses app-of-apps pattern: root app manages infrastructure + services apps
- External Secrets integrates with AWS Secrets Manager/SSM
- OpenTelemetry is pre-configured in Go services
- Database migrations use Atlas, run as init containers
- Pod identity (not IRSA) is used for AWS IAM
