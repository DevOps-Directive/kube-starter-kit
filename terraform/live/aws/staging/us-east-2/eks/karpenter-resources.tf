# This doesnt actually install Karpenter, it just sets up the AWS resources that live outside of the cluster
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/karpenter#all-resources-default
# Could install via terraform + helm like this https://github.com/terraform-aws-modules/terraform-aws-eks/blob/de2aa10f25c7f2d2ab1264f6451f7cbf57f784c4/examples/karpenter/main.tf#L134-L162
# OR could install/manage like any other helm charts we end up installing with gitops (flux/argo/kluctl)
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.3.1"

  cluster_name = module.eks.cluster_name

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix   = false
  node_iam_role_name              = "KarpenterNodeRole-${local.name}"
  create_pod_identity_association = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}
