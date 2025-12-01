remote_state {
  backend = "s3"
  config  = {
    bucket         = "ksk-gbl-infra-bootstrap-state"
    key            = "terraform/live/${path_relative_to_include()}.tfstate"
    region         = "us-east-2"
    use_lockfile = "true"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = {
  namespace = "ksk" # kube-starter-kit
  github_oidc_assume_role_arn = "arn:aws:iam::094905625236:role/ksk-gbl-infra-bootstrap-github-oidc" 
  sso_admin_assume_role_arn = "arn:aws:iam::094905625236:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_80ecc41059967962"
}
