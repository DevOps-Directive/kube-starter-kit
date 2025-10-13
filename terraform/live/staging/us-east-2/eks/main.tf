terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.terraform_iam_role_arn
  }
}

data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


locals {
  name               = "staging-us-east-2"
  kubernetes_version = "1.33"
  region             = "us-east-2"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.3.1"

  name               = local.name
  kubernetes_version = "1.33"

  access_entries = {
    example = {
      principal_arn = "arn:aws:iam::038198578795:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AWSAdministratorAccess_bf4f5a0626f509cb"

      policy_associations = {
        example = {
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
  # # only necessary if deploying karpenter from TF...
  # enable_cluster_creator_admin_permissions = true

  enable_irsa            = true
  endpoint_public_access = true

  # TODO: specify versions
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    aws-ebs-csi-driver = {}

  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  eks_managed_node_groups = {
    karpenter = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.medium"]

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
    "karpenter.sh/discovery" = local.name
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
