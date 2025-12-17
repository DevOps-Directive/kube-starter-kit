// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "bootstrapping" {
  aws_region                  = "us-east-2"
  create_zone                 = true
  environment                 = "gbl"
  github_oidc_assume_role_arn = "arn:aws:iam::038198578795:role/github-oidc-provider-aws-chain"
  name                        = "bootstrap"
  namespace                   = "ksk"
  source                      = "../../../../modules//account-bootstrapping"
  sso_admin_assume_role_arn   = "arn:aws:iam::038198578795:role/AWSReservedSSO_AdministratorAccess_c43fd52097fda498"
  stage                       = "staging"
  terraform_iam_role_arn      = "arn:aws:iam::038198578795:role/ksk-gbl-staging-bootstrap-admin"
  zone_external_dns_owner     = "external-dns"
  zone_name                   = "staging.kubestarterkit.com"
}
