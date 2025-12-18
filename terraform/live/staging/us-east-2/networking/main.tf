// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "networking" {
  aws_region                        = "us-east-2"
  enable_bastion                    = true
  environment                       = "use2"
  environment_name                  = "staging"
  name                              = "network"
  namespace                         = "ksk"
  nat_mode                          = "fck_nat"
  planetscale_endpoint_service_name = "com.amazonaws.vpce.us-east-2.vpce-svc-069f88c102c1a7fba"
  source                            = "../../../../../terraform/modules//networking"
  stage                             = "staging"
  terraform_iam_role_arn            = "arn:aws:iam::038198578795:role/ksk-gbl-staging-bootstrap-admin"
  vpc_cidr                          = "10.0.0.0/16"
}
