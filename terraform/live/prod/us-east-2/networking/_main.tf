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
  source                            = "git::https://github.com/DevOps-Directive/kube-starter-kit.git//terraform/modules/networking?ref=terraform/modules/networking@0.1.0"
  stage                             = "prod"
  terraform_iam_role_arn            = "DUMMY"
  vpc_cidr                          = "10.2.0.0/16"
}
