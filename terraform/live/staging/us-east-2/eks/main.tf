terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

module "eks-wrapper" {
  source = "../../../../modules/eks"

  environment_name       = var.environment_name
  aws_region             = var.aws_region
  terraform_iam_role_arn = var.terraform_iam_role_arn
  vpc_id                 = var.vpc_id
  private_subnets        = var.private_subnets

}


moved {
  from = module.eks
  to   = module.eks-wrapper.module.eks
}

moved {
  from = module.karpenter
  to   = module.eks-wrapper.module.karpenter
}

moved {
  from = tls_private_key.deploy_key
  to   = module.eks-wrapper.tls_private_key.deploy_key
}

moved {
  from = module.secrets_manager_json
  to   = module.eks-wrapper.module.secrets_manager_json
}

moved {
  from = module.external_secrets_pod_identity
  to   = module.eks-wrapper.module.external_secrets_pod_identity
}

moved {
  from = module.aws_ebs_csi_pod_identity
  to   = module.eks-wrapper.module.aws_ebs_csi_pod_identity
}


moved {
  from = module.external_dns_pod_identity
  to   = module.eks-wrapper.module.external_dns_pod_identity
}

moved {
  from = module.cert_manager_pod_identity
  to   = module.eks-wrapper.module.cert_manager_pod_identity
}


