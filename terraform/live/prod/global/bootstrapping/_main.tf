// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

import {
  id = "ksk-gbl-prod-bootstrap-admin"
  to = module.bootstrapping.module.iam_role.aws_iam_role.this[0]
}
module "bootstrapping" {
  aws_region                  = "us-east-2"
  create_zone                 = true
  environment                 = "gbl"
  github_oidc_assume_role_arn = "arn:aws:iam::094905625236:role/ksk-gbl-infra-bootstrap-github-oidc"
  name                        = "bootstrap"
  namespace                   = "ksk"
  source                      = "../../../../../terraform/modules//account-bootstrapping"
  sso_admin_assume_role_arn   = "arn:aws:iam::094905625236:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_80ecc41059967962"
  stage                       = "prod"
  terraform_iam_role_arn      = "DUMMY"
  zone_external_dns_owner     = "external-dns"
  zone_name                   = "prod.kubestarterkit.com"
}
