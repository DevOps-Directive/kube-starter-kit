################################################################################
# ArgoCD GitHub Webhook Secret
# The webhook itself must be created manually in GitHub (see argocd_webhook_setup output)
# because octo-sts doesn't have webhook permissions.
################################################################################

# Generate a random secret for the GitHub webhook
resource "random_password" "argocd_webhook_secret" {
  length  = 32
  special = false
}

# Store the webhook secret in AWS Secrets Manager for ExternalSecrets to consume
module "argocd_webhook_secret" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "2.0.1"

  name                    = "${module.this.id}-argocd-github-webhook"
  description             = "GitHub webhook secret for ArgoCD"
  recovery_window_in_days = 7

  secret_string = jsonencode({
    "webhookSecret" = random_password.argocd_webhook_secret.result
  })
}

