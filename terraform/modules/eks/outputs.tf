output "deploy_key_public_key" {
  value = tls_private_key.deploy_key.public_key_openssh
}

output "deploy_key_setup" {
  description = "Instructions for setting up the GitHub deploy key"
  value       = <<-EOT
    ┌─────────────────────────────────────────────────────────────────────────────┐
    │ GitHub Deploy Key Setup                                                     │
    ├─────────────────────────────────────────────────────────────────────────────┤
    │ Go to: https://github.com/<GH_ORG>/${var.github_repository}/settings/keys/new
    │                                                                             │
    │ Configuration:                                                              │
    │   • Title:        ArgoCD Deploy Key (${module.this.id})                     │
    │   • Key:          (see below)                                               │
    │   • Allow write:  ☐ (read-only is sufficient for GitOps)                    │
    │                                                                             │
    │ Public key:                                                                 │
    │   ${tls_private_key.deploy_key.public_key_openssh}
    └─────────────────────────────────────────────────────────────────────────────┘
  EOT
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "karpenter_interruption_queue" {
  value = module.karpenter.queue_name
}

output "karpenter_node_role_name" {
  value = local.karpenter_node_role_name
}

output "argocd_webhook_setup" {
  description = "Instructions for setting up the ArgoCD GitHub webhook manually"
  value       = <<-EOT
    ┌─────────────────────────────────────────────────────────────────────────────┐
    │ ArgoCD GitHub Webhook Setup                                                 │
    ├─────────────────────────────────────────────────────────────────────────────┤
    │ Go to: https://github.com/<GH_ORG>/${var.github_repository}/settings/hooks/new
    │                                                                             │
    │ Configuration:                                                              │
    │   • Payload URL:  https://${var.argocd_hostname}/api/webhook                │
    │   • Content type: application/json                                          │
    │   • Secret:       (see below)                                               │
    │   • SSL:          Enable SSL verification                                   │
    │   • Events:       Just the push event                                       │
    │                                                                             │
    │ To retrieve the webhook secret from AWS Secrets Manager:                    │
    │   aws secretsmanager get-secret-value \                                     │
    │     --secret-id ${module.argocd_webhook_secret.secret_id} \                 │
    │     --query 'SecretString' --output text | jq -r '.webhookSecret'           │
    └─────────────────────────────────────────────────────────────────────────────┘
  EOT
}
