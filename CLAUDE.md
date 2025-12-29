# CLAUDE.md - Kube Starter Kit

## Project Overview

Kube Starter Kit is a production-ready Kubernetes platform starter for AWS EKS environments. It provides infrastructure-as-code, GitOps deployments, CI/CD pipelines, and example applications designed for early-stage engineering teams to bootstrap a complete Kubernetes platform.

## Quick Start

```bash
# Install tools for current directory context
mise install

# List available tasks (context-aware)
mise tasks
```

## Directory Structure

```
kube-starter-kit/
├── .github/workflows/      # CI/CD pipelines (build, deploy, drift detection)
├── docs/                   # Mintlify documentation site
├── kubernetes/
│   ├── src/               # Source manifests (templates)
│   │   ├── argocd/        # ArgoCD app-of-apps definitions
│   │   ├── infrastructure/ # Cluster components (cert-manager, ingress, etc.)
│   │   └── services/      # Application deployments
│   └── rendered/          # Generated manifests by environment
├── local/
│   ├── kind/              # KinD cluster config + registry script
│   └── tilt/              # Tiltfile for local dev
├── services/              # Application source code (Go backends)
├── terraform/
│   ├── bootstrap/         # Initial AWS account setup
│   ├── modules/           # Reusable modules (eks, networking, etc.)
│   └── live/              # Environment-specific configs (staging, production)
└── tools/                 # Shared mise tasks
```

## Key Patterns

### Mise Tasks

Tasks are hierarchical across the monorepo. Run `mise tasks` in any directory to see available commands for that context.

### Kubernetes Deployment

Three equivalent templating approaches are demonstrated with `go-backend`: Kustomize, Helm, and Timoni. All render to `kubernetes/rendered/{environment}/`.

### GitOps

ArgoCD uses the app-of-apps pattern: a root app in `kubernetes/src/argocd/` manages both infrastructure components and service deployments.

## Development Workflow

1. **Local testing**: Use KinD + Tilt (run `mise tasks` in `local/`)
2. **Make changes**: Edit source in `kubernetes/src/` or `services/`
3. **Render manifests**: Run `mise run render-cluster <cluster>` from each application directory in `kubernetes/src/`
4. **Commit**: Include rendered manifests (CI validates they're current)
5. **Merge**: ArgoCD syncs changes to staging automatically

## Architecture Notes

- External Secrets integrates with AWS Secrets Manager/SSM
- OpenTelemetry is pre-configured in Go services
- Database migrations use Atlas, run as Kubernetes Jobs with Argo CD sync wave ordering
- Pod identity (not IRSA) is used for AWS IAM
- Terraform orchestration is managed by Terramate (see `terraform/` and `.github/workflows/terramate-*.yml`)