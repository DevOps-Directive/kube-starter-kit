# Input from EKS stack
input "eks_cluster_name" {
  backend       = "terraform"
  from_stack_id = "staging-use2-eks"
  value         = outputs.eks_cluster_name.value
  mock          = "mock-cluster-name"
}
