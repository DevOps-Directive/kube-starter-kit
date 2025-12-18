// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "networking" {
  aws_region                        = "us-east-1"
  enable_bastion                    = true
  environment                       = "use1"
  environment_name                  = "staging"
  name                              = "network"
  namespace                         = "ksk"
  nat_mode                          = "fck_nat"
  planetscale_endpoint_service_name = "com.amazonaws.vpce.us-east-1.vpce-svc-02fef31be60d3fd35"
  source                            = "../../../../../terraform/modules//networking"
  stage                             = "staging"
  terraform_iam_role_arn            = "arn:aws:iam::038198578795:role/ksk-gbl-staging-bootstrap-admin"
  vpc_cidr                          = "10.1.0.0/16"
}
