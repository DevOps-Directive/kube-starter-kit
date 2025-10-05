# Will be used as deploy key
resource "tls_private_key" "deploy_key" {
  algorithm = "ED25519"
}

module "secrets_manager" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "2.0.0"

  # Secret
  name_prefix             = "deploy-key" # TODO: Use Actual Name
  description             = "Deploy Key for GitOps Controller"
  recovery_window_in_days = 7 # TODO: Lengthen?

  secret_string = tls_private_key.deploy_key.private_key_openssh

}

# TODO: 
# - Set up ExternalSecretOperator
# - Create ExternalSecret during gitops bootstrapping
# - Document bootstrapping process
