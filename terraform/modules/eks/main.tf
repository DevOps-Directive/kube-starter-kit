data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


locals {
  region                   = var.aws_region
  azs                      = slice(data.aws_availability_zones.available.names, 0, 3)
  karpenter_node_role_name = "${module.this.id}-KarpenterNodeRole"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.3.1"

  name               = module.this.id
  kubernetes_version = var.kubernetes_version

  access_entries = {
    sso_admin = {
      principal_arn = var.admin_sso_role_arn

      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # # Gives Terraform identity admin access to cluster which will
  # # allow deploying resources (Karpenter) into the cluster
  # # only necessary if deploying applications from TF (e.g. via https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
  # enable_cluster_creator_admin_permissions = true

  enable_irsa             = true
  endpoint_public_access  = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access

  # Allow VPC traffic to reach the private API endpoint (for bastion access)
  security_group_additional_rules = var.vpc_cidr != null ? {
    ingress_vpc_443 = {
      description = "HTTPS from VPC (for private endpoint access)"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [var.vpc_cidr]
    }
  } : {}

  addons = {
    coredns = {
      addon_version               = var.eks_addon_versions.coredns
      resolve_conflicts_on_update = "OVERWRITE"
    }

    eks-pod-identity-agent = {
      before_compute              = true
      addon_version               = var.eks_addon_versions.eks_pod_identity_agent
      resolve_conflicts_on_update = "OVERWRITE"
    }

    kube-proxy = {
      addon_version               = var.eks_addon_versions.kube_proxy
      resolve_conflicts_on_update = "OVERWRITE"
    }

    vpc-cni = {
      before_compute              = true
      addon_version               = var.eks_addon_versions.vpc_cni
      resolve_conflicts_on_update = "OVERWRITE"
    }

    aws-ebs-csi-driver = {
      addon_version               = var.eks_addon_versions.aws_ebs_csi_driver
      resolve_conflicts_on_update = "OVERWRITE"
    }

  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  eks_managed_node_groups = {
    base = {
      # Node group version can be pinned independently:
      version = var.base_node_group_kubernetes_version

      ami_type       = var.base_node_group_ami_type
      instance_types = var.base_node_group_instance_types

      min_size     = 2
      max_size     = 3
      desired_size = 2

      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }
    }
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = module.this.id
  }

  ######################################################
  #
  # By default, EKS module security groups only allow inter-node communication on unpriviledged ports (greater than 1024)
  # If you need your pods to listen on other ports (e.g. 80, 443, etc...) you must add a rule to allow that traffic.
  # See: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/74824da9c4fe9dd0b405db70881a1158fa1af216/node_groups.tf#L112-L119
  #
  ######################################################
  # node_security_group_additional_rules = {
  #   allow_self_http = {
  #     description = "Allow node-to-node HTTP"
  #     protocol    = "tcp"
  #     from_port   = "<BEGINNING_OF_RANGE>"
  #     to_port     = "<END_OF_RANGE>"
  #     type        = "ingress"
  #     self        = true
  #   }
  # }
  ######################################################
}

