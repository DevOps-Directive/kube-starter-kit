// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

import {
  id = "ksk-gbl-mgmt-bootstrap-admin"
  to = module.bootstrapping.module.iam_role.aws_iam_role.this[0]
}
module "bootstrapping" {
  aws_region                  = "us-east-2"
  create_zone                 = false
  environment                 = "gbl"
  github_oidc_assume_role_arn = "arn:aws:iam::094905625236:role/ksk-gbl-infra-bootstrap-github-oidc"
  name                        = "bootstrap"
  namespace                   = "ksk"
  source                      = "../../../../../terraform/modules//account-bootstrapping"
  sso_admin_assume_role_arn   = "arn:aws:iam::094905625236:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_80ecc41059967962"
  stage                       = "mgmt"
  terraform_iam_role_arn      = "arn:aws:iam::085164809580:role/ksk-gbl-mgmt-bootstrap-admin"
  zone_external_dns_owner     = null
  zone_name                   = null
}
