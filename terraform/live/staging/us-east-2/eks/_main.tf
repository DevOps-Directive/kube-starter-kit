// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "eks" {
  admin_sso_role_arn                  = "arn:aws:iam::038198578795:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_47aa578228eb79ff"
  argocd_hostname                     = "argocd.staging.kubestarterkit.com"
  aws_region                          = "us-east-2"
  base_node_group_ami_release_version = null
  base_node_group_kubernetes_version  = "1.34"
  endpoint_private_access             = true
  endpoint_public_access              = false
  environment                         = "use2"
  kubernetes_version                  = "1.34"
  name                                = "eks"
  namespace                           = "ksk"
  private_subnets                     = var.private_subnets
  route53_zone_arn                    = var.route53_zone_arn
  source                              = "../../../../../terraform/modules//eks"
  stage                               = "staging"
  terraform_iam_role_arn              = "arn:aws:iam::038198578795:role/ksk-gbl-staging-bootstrap-admin"
  vpc_cidr                            = var.vpc_cidr
  vpc_id                              = var.vpc_id
}
