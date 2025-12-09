# NOTE:  These could be moved to the account level and shared across clusters
module "external_secrets_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.0.0"

  name = "${module.eks.cluster_name}-external-secrets"

  attach_external_secrets_policy = true
  # NOTE: These could be limited to a subset of secrets using a name prefix or tag condition
  external_secrets_ssm_parameter_arns   = ["arn:aws:ssm:*:*:parameter/*"]
  external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:*:*:secret:*"]
  external_secrets_create_permission    = true # Necessary to use https://external-secrets.io/latest/api/pushsecret/

  association_defaults = {
    namespace       = "external-secrets"
    service_account = "external-secrets"
  }

  associations = {
    this = {
      cluster_name = module.eks.cluster_name
    }
  }
}

module "aws_ebs_csi_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.0.0"

  name = "${module.eks.cluster_name}-aws-ebs-csi"

  attach_aws_ebs_csi_policy = true

  association_defaults = {
    namespace       = "kube-system"
    service_account = "ebs-csi-controller-sa"
  }

  associations = {
    this = {
      cluster_name = module.eks.cluster_name
    }
  }
}

module "external_dns_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.0.0"

  name = "${module.eks.cluster_name}-external-dns"

  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = [var.route53_zone_arn]

  association_defaults = {
    namespace       = "external-dns"
    service_account = "external-dns"
  }

  associations = {
    this = {
      cluster_name = module.eks.cluster_name
    }
  }

}

module "cert_manager_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.0.0"

  name = "${module.eks.cluster_name}-cert-manager"

  attach_cert_manager_policy = true
  # Extension: Support multiple zones
  cert_manager_hosted_zone_arns = [var.route53_zone_arn]

  association_defaults = {
    namespace       = "cert-manager"
    service_account = "cert-manager"
  }

  associations = {
    this = {
      cluster_name = module.eks.cluster_name
    }
  }
}

module "kargo_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.0.0"

  name = "${module.eks.cluster_name}-kargo"

  additional_policy_arns = {
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  association_defaults = {
    namespace       = "kargo"
    service_account = "kargo-controller"
  }

  associations = {
    this = {
      cluster_name = module.eks.cluster_name
    }
  }
}
