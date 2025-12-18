// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "bootstrapping" {
  aws_region                  = "us-east-2"
  create_zone                 = true
  environment                 = "gbl"
  github_oidc_assume_role_arn = "arn:aws:iam::094905625236:role/ksk-gbl-infra-bootstrap-github-oidc"
  name                        = "bootstrap"
  namespace                   = "ksk"
  source                      = "../../../../../terraform/modules//account-bootstrapping"
  sso_admin_assume_role_arn   = "arn:aws:iam::094905625236:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_80ecc41059967962"
  stage                       = "staging"
  terraform_iam_role_arn      = "arn:aws:iam::038198578795:role/ksk-gbl-staging-bootstrap-admin"
  zone_external_dns_owner     = "external-dns"
  zone_name                   = "staging.kubestarterkit.com"
}
