# Kube Starter Kit

A production-ready Kubernetes platform starter for AWS EKS. Infrastructure-as-code, GitOps, CI/CD pipelines, and example applications for early-stage engineering teams.

**Docs:** https://kubestarterkit.com/

## Quick Start

```bash
mise install    # Install tools
mise task ls --all   # List available commands
```

## Structure

```
kubernetes/     # K8s manifests (source + rendered)
terraform/      # Infrastructure (EKS, networking, etc.)
services/       # Application source code
local/          # Local dev (KinD + Tilt)
.github/        # CI/CD workflows
```

## Key Features

| Feature | Description |
|---------|-------------|
| **Terraform Infrastructure** | Modular Terraform for AWS with multi-environment support |
| **Terramate Orchestration** | Stack-based orchestration with change detection and CI/CD integration |
| **AWS Architecture** | Multi-account setup with VPC, EKS, and secure account boundaries |
| **User Management** | Unified identity via GitHub with AWS IAM Identity Center |
| **GitOps Deployment** | ArgoCD-based declarative, auditable deployments |
| **Kubernetes Baseline** | Ingress, cert-manager, external-dns, secrets, observability |
| **CI/CD Pipelines** | Automated container builds and staging deployments |
| **Image CVE Scanning** | Automated vulnerability scanning with daily scheduled scans |
| **Release Management** | Automated release PRs with release-please |
| **Demo Applications** | Fully functional examples demonstrating end-to-end patterns |
| **Local Development** | KinD, Tilt, and mirrord for fast local development |
