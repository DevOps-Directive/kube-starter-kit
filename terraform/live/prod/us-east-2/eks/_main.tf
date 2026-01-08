// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "eks" {
  admin_sso_role_arn                  = "arn:aws:iam::964263445142:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_61e32a1d3786074b"
  argocd_hostname                     = "argocd.prod.kubestarterkit.com"
  aws_region                          = "us-east-2"
  base_node_group_ami_release_version = null
  base_node_group_kubernetes_version  = "1.34"
  eks_addon_versions                  = null
  endpoint_private_access             = true
  endpoint_public_access              = false
  environment                         = "use2"
  kubernetes_version                  = "1.34"
  name                                = "eks"
  namespace                           = "ksk"
  private_subnets                     = var.private_subnets
  route53_zone_arn                    = var.route53_zone_arn
  source                              = "git::https://github.com/DevOps-Directive/kube-starter-kit.git//terraform/modules/eks?ref=terraform/modules/eks@0.1.0"
  stage                               = "prod"
  terraform_iam_role_arn              = "DUMMY"
  vpc_cidr                            = var.vpc_cidr
  vpc_id                              = var.vpc_id
}
