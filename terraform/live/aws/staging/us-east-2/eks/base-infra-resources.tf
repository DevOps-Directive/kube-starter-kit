
module "external_secrets_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.0.0"

  name = "external-secrets"

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
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "aws-ebs-csi"

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
