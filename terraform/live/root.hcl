locals {
  # BOOTSTRAP: Set these manually after they exist
  github_oidc_assume_role_arn = "arn:aws:iam::094905625236:role/github-oidc-provider-aws" 
  sso_admin_assume_role_arn = "arn:aws:iam::094905625236:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AWSAdministratorAccess_fa7ea65862c3f54a"
}

remote_state {
  backend = "s3"
  
  config  = {
    bucket         = "kube-starter-kit-tf-state"
    key            = "terraform/live/${path_relative_to_include()}.tfstate"
    region         = "us-east-2"
    use_lockfile = "true"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
