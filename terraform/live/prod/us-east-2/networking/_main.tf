// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "networking" {
  aws_region                        = "us-east-2"
  enable_bastion                    = true
  environment                       = "use2"
  environment_name                  = "prod"
  name                              = "network"
  namespace                         = "ksk"
  nat_mode                          = "one_nat_gateway_per_az"
  planetscale_endpoint_service_name = "com.amazonaws.vpce.us-east-2.vpce-svc-069f88c102c1a7fba"
  source                            = "../../../../../terraform/modules//networking"
  stage                             = "prod"
  terraform_iam_role_arn            = "arn:aws:iam::964263445142:role/ksk-gbl-prod-bootstrap-admin"
  vpc_cidr                          = "10.2.0.0/16"
}
