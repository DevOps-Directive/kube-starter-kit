#!/bin/bash
# State migration script for staging/us-east-2/eks
# Migrates state from root-level modules to module.eks.* prefix
#
# Run with: ./state-migration.sh
# Or dry-run: DRY_RUN=1 ./state-migration.sh

set -e

DRY_RUN="${DRY_RUN:-0}"

run_cmd() {
  if [ "$DRY_RUN" = "1" ]; then
    echo "[DRY-RUN] $*"
  else
    echo "[RUNNING] $*"
    "$@"
  fi
}

echo "=== State Migration: staging/us-east-2/eks ==="
echo "Moving resources from root level to module.eks.*"
echo ""

# Root-level resources
run_cmd terraform state mv 'random_password.argocd_webhook_secret' 'module.eks.random_password.argocd_webhook_secret'
run_cmd terraform state mv 'tls_private_key.deploy_key' 'module.eks.tls_private_key.deploy_key'

# ArgoCD webhook secret
run_cmd terraform state mv 'module.argocd_webhook_secret.aws_secretsmanager_secret.this[0]' 'module.eks.module.argocd_webhook_secret.aws_secretsmanager_secret.this[0]'
run_cmd terraform state mv 'module.argocd_webhook_secret.aws_secretsmanager_secret_version.this[0]' 'module.eks.module.argocd_webhook_secret.aws_secretsmanager_secret_version.this[0]'

# EBS CSI pod identity
run_cmd terraform state mv 'module.aws_ebs_csi_pod_identity.aws_eks_pod_identity_association.this["this"]' 'module.eks.module.aws_ebs_csi_pod_identity.aws_eks_pod_identity_association.this["this"]'
run_cmd terraform state mv 'module.aws_ebs_csi_pod_identity.aws_iam_policy.ebs_csi[0]' 'module.eks.module.aws_ebs_csi_pod_identity.aws_iam_policy.ebs_csi[0]'
run_cmd terraform state mv 'module.aws_ebs_csi_pod_identity.aws_iam_role.this[0]' 'module.eks.module.aws_ebs_csi_pod_identity.aws_iam_role.this[0]'
run_cmd terraform state mv 'module.aws_ebs_csi_pod_identity.aws_iam_role_policy_attachment.ebs_csi[0]' 'module.eks.module.aws_ebs_csi_pod_identity.aws_iam_role_policy_attachment.ebs_csi[0]'

# Cert manager pod identity
run_cmd terraform state mv 'module.cert_manager_pod_identity.aws_eks_pod_identity_association.this["this"]' 'module.eks.module.cert_manager_pod_identity.aws_eks_pod_identity_association.this["this"]'
run_cmd terraform state mv 'module.cert_manager_pod_identity.aws_iam_policy.cert_manager[0]' 'module.eks.module.cert_manager_pod_identity.aws_iam_policy.cert_manager[0]'
run_cmd terraform state mv 'module.cert_manager_pod_identity.aws_iam_role.this[0]' 'module.eks.module.cert_manager_pod_identity.aws_iam_role.this[0]'
run_cmd terraform state mv 'module.cert_manager_pod_identity.aws_iam_role_policy_attachment.cert_manager[0]' 'module.eks.module.cert_manager_pod_identity.aws_iam_role_policy_attachment.cert_manager[0]'

# External DNS pod identity
run_cmd terraform state mv 'module.external_dns_pod_identity.aws_eks_pod_identity_association.this["this"]' 'module.eks.module.external_dns_pod_identity.aws_eks_pod_identity_association.this["this"]'
run_cmd terraform state mv 'module.external_dns_pod_identity.aws_iam_policy.external_dns[0]' 'module.eks.module.external_dns_pod_identity.aws_iam_policy.external_dns[0]'
run_cmd terraform state mv 'module.external_dns_pod_identity.aws_iam_role.this[0]' 'module.eks.module.external_dns_pod_identity.aws_iam_role.this[0]'
run_cmd terraform state mv 'module.external_dns_pod_identity.aws_iam_role_policy_attachment.external_dns[0]' 'module.eks.module.external_dns_pod_identity.aws_iam_role_policy_attachment.external_dns[0]'

# External Secrets pod identity
run_cmd terraform state mv 'module.external_secrets_pod_identity.aws_eks_pod_identity_association.this["this"]' 'module.eks.module.external_secrets_pod_identity.aws_eks_pod_identity_association.this["this"]'
run_cmd terraform state mv 'module.external_secrets_pod_identity.aws_iam_policy.external_secrets[0]' 'module.eks.module.external_secrets_pod_identity.aws_iam_policy.external_secrets[0]'
run_cmd terraform state mv 'module.external_secrets_pod_identity.aws_iam_role.this[0]' 'module.eks.module.external_secrets_pod_identity.aws_iam_role.this[0]'
run_cmd terraform state mv 'module.external_secrets_pod_identity.aws_iam_role_policy_attachment.external_secrets[0]' 'module.eks.module.external_secrets_pod_identity.aws_iam_role_policy_attachment.external_secrets[0]'

# Kargo pod identity
run_cmd terraform state mv 'module.kargo_pod_identity.aws_eks_pod_identity_association.this["this"]' 'module.eks.module.kargo_pod_identity.aws_eks_pod_identity_association.this["this"]'
run_cmd terraform state mv 'module.kargo_pod_identity.aws_iam_role.this[0]' 'module.eks.module.kargo_pod_identity.aws_iam_role.this[0]'
run_cmd terraform state mv 'module.kargo_pod_identity.aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"]' 'module.eks.module.kargo_pod_identity.aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"]'

# EKS cluster module
run_cmd terraform state mv 'module.eks.aws_cloudwatch_log_group.this[0]' 'module.eks.module.eks.aws_cloudwatch_log_group.this[0]'
run_cmd terraform state mv 'module.eks.aws_eks_access_entry.this["sso_admin"]' 'module.eks.module.eks.aws_eks_access_entry.this["sso_admin"]'
run_cmd terraform state mv 'module.eks.aws_eks_access_policy_association.this["sso_admin_cluster_admin"]' 'module.eks.module.eks.aws_eks_access_policy_association.this["sso_admin_cluster_admin"]'
run_cmd terraform state mv 'module.eks.aws_eks_addon.before_compute["eks-pod-identity-agent"]' 'module.eks.module.eks.aws_eks_addon.before_compute["eks-pod-identity-agent"]'
run_cmd terraform state mv 'module.eks.aws_eks_addon.before_compute["vpc-cni"]' 'module.eks.module.eks.aws_eks_addon.before_compute["vpc-cni"]'
run_cmd terraform state mv 'module.eks.aws_eks_addon.this["aws-ebs-csi-driver"]' 'module.eks.module.eks.aws_eks_addon.this["aws-ebs-csi-driver"]'
run_cmd terraform state mv 'module.eks.aws_eks_addon.this["coredns"]' 'module.eks.module.eks.aws_eks_addon.this["coredns"]'
run_cmd terraform state mv 'module.eks.aws_eks_addon.this["kube-proxy"]' 'module.eks.module.eks.aws_eks_addon.this["kube-proxy"]'
run_cmd terraform state mv 'module.eks.aws_eks_cluster.this[0]' 'module.eks.module.eks.aws_eks_cluster.this[0]'
run_cmd terraform state mv 'module.eks.aws_iam_openid_connect_provider.oidc_provider[0]' 'module.eks.module.eks.aws_iam_openid_connect_provider.oidc_provider[0]'
run_cmd terraform state mv 'module.eks.aws_iam_policy.cluster_encryption[0]' 'module.eks.module.eks.aws_iam_policy.cluster_encryption[0]'
run_cmd terraform state mv 'module.eks.aws_iam_role.this[0]' 'module.eks.module.eks.aws_iam_role.this[0]'
run_cmd terraform state mv 'module.eks.aws_iam_role_policy_attachment.cluster_encryption[0]' 'module.eks.module.eks.aws_iam_role_policy_attachment.cluster_encryption[0]'
run_cmd terraform state mv 'module.eks.aws_iam_role_policy_attachment.this["AmazonEKSClusterPolicy"]' 'module.eks.module.eks.aws_iam_role_policy_attachment.this["AmazonEKSClusterPolicy"]'
run_cmd terraform state mv 'module.eks.aws_security_group.cluster[0]' 'module.eks.module.eks.aws_security_group.cluster[0]'
run_cmd terraform state mv 'module.eks.aws_security_group.node[0]' 'module.eks.module.eks.aws_security_group.node[0]'
run_cmd terraform state mv 'module.eks.aws_security_group_rule.cluster["ingress_nodes_443"]' 'module.eks.module.eks.aws_security_group_rule.cluster["ingress_nodes_443"]'
run_cmd terraform state mv 'module.eks.aws_security_group_rule.cluster["ingress_vpc_443"]' 'module.eks.module.eks.aws_security_group_rule.cluster["ingress_vpc_443"]'
run_cmd terraform state mv 'module.eks.aws_security_group_rule.node["egress_all"]' 'module.eks.module.eks.aws_security_group_rule.node["egress_all"]'
run_cmd terraform state mv 'module.eks.aws_security_group_rule.node["ingress_cluster_443"]' 'module.eks.module.eks.aws_security_group_rule.node["ingress_cluster_443"]'
run_cmd terraform state mv 'module.eks.aws_security_group_rule.node["ingress_cluster_4443_webhook"]' 'module.eks.module.eks.aws_security_group_rule.node["ingress_cluster_4443_webhook"]'
run_cmd terraform state mv 'module.eks.aws_security_group_rule.node["ingress_cluster_6443_webhook"]' 'module.eks.module.eks.aws_security_group_rule.node["ingress_cluster_6443_webhook"]'
run_cmd terraform state mv 'module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"]' 'module.eks.module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"]'
run_cmd terraform state mv 'module.eks.aws_security_group_rule.node["ingress_cluster_9443_webhook"]' 'module.eks.module.eks.aws_security_group_rule.node["ingress_cluster_9443_webhook"]'
run_cmd terraform state mv 'module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"]' 'module.eks.module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"]'
run_cmd terraform state mv 'module.eks.aws_security_group_rule.node["ingress_nodes_ephemeral"]' 'module.eks.module.eks.aws_security_group_rule.node["ingress_nodes_ephemeral"]'
run_cmd terraform state mv 'module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]' 'module.eks.module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]'
run_cmd terraform state mv 'module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"]' 'module.eks.module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"]'
run_cmd terraform state mv 'module.eks.time_sleep.this[0]' 'module.eks.module.eks.time_sleep.this[0]'

# EKS managed node group
run_cmd terraform state mv 'module.eks.module.eks_managed_node_group["base"].aws_eks_node_group.this[0]' 'module.eks.module.eks.module.eks_managed_node_group["base"].aws_eks_node_group.this[0]'
run_cmd terraform state mv 'module.eks.module.eks_managed_node_group["base"].aws_iam_role.this[0]' 'module.eks.module.eks.module.eks_managed_node_group["base"].aws_iam_role.this[0]'
run_cmd terraform state mv 'module.eks.module.eks_managed_node_group["base"].aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"]' 'module.eks.module.eks.module.eks_managed_node_group["base"].aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"]'
run_cmd terraform state mv 'module.eks.module.eks_managed_node_group["base"].aws_iam_role_policy_attachment.this["AmazonEKSWorkerNodePolicy"]' 'module.eks.module.eks.module.eks_managed_node_group["base"].aws_iam_role_policy_attachment.this["AmazonEKSWorkerNodePolicy"]'
run_cmd terraform state mv 'module.eks.module.eks_managed_node_group["base"].aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"]' 'module.eks.module.eks.module.eks_managed_node_group["base"].aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"]'
run_cmd terraform state mv 'module.eks.module.eks_managed_node_group["base"].aws_launch_template.this[0]' 'module.eks.module.eks.module.eks_managed_node_group["base"].aws_launch_template.this[0]'

# KMS module
run_cmd terraform state mv 'module.eks.module.kms.aws_kms_alias.this["cluster"]' 'module.eks.module.eks.module.kms.aws_kms_alias.this["cluster"]'
run_cmd terraform state mv 'module.eks.module.kms.aws_kms_key.this[0]' 'module.eks.module.eks.module.kms.aws_kms_key.this[0]'

# Karpenter module
run_cmd terraform state mv 'module.karpenter.aws_cloudwatch_event_rule.this["health_event"]' 'module.eks.module.karpenter.aws_cloudwatch_event_rule.this["health_event"]'
run_cmd terraform state mv 'module.karpenter.aws_cloudwatch_event_rule.this["instance_rebalance"]' 'module.eks.module.karpenter.aws_cloudwatch_event_rule.this["instance_rebalance"]'
run_cmd terraform state mv 'module.karpenter.aws_cloudwatch_event_rule.this["instance_state_change"]' 'module.eks.module.karpenter.aws_cloudwatch_event_rule.this["instance_state_change"]'
run_cmd terraform state mv 'module.karpenter.aws_cloudwatch_event_rule.this["spot_interrupt"]' 'module.eks.module.karpenter.aws_cloudwatch_event_rule.this["spot_interrupt"]'
run_cmd terraform state mv 'module.karpenter.aws_cloudwatch_event_target.this["health_event"]' 'module.eks.module.karpenter.aws_cloudwatch_event_target.this["health_event"]'
run_cmd terraform state mv 'module.karpenter.aws_cloudwatch_event_target.this["instance_rebalance"]' 'module.eks.module.karpenter.aws_cloudwatch_event_target.this["instance_rebalance"]'
run_cmd terraform state mv 'module.karpenter.aws_cloudwatch_event_target.this["instance_state_change"]' 'module.eks.module.karpenter.aws_cloudwatch_event_target.this["instance_state_change"]'
run_cmd terraform state mv 'module.karpenter.aws_cloudwatch_event_target.this["spot_interrupt"]' 'module.eks.module.karpenter.aws_cloudwatch_event_target.this["spot_interrupt"]'
run_cmd terraform state mv 'module.karpenter.aws_eks_access_entry.node[0]' 'module.eks.module.karpenter.aws_eks_access_entry.node[0]'
run_cmd terraform state mv 'module.karpenter.aws_eks_pod_identity_association.karpenter[0]' 'module.eks.module.karpenter.aws_eks_pod_identity_association.karpenter[0]'
run_cmd terraform state mv 'module.karpenter.aws_iam_policy.controller[0]' 'module.eks.module.karpenter.aws_iam_policy.controller[0]'
run_cmd terraform state mv 'module.karpenter.aws_iam_role.controller[0]' 'module.eks.module.karpenter.aws_iam_role.controller[0]'
run_cmd terraform state mv 'module.karpenter.aws_iam_role.node[0]' 'module.eks.module.karpenter.aws_iam_role.node[0]'
run_cmd terraform state mv 'module.karpenter.aws_iam_role_policy_attachment.controller[0]' 'module.eks.module.karpenter.aws_iam_role_policy_attachment.controller[0]'
run_cmd terraform state mv 'module.karpenter.aws_iam_role_policy_attachment.node["AmazonEC2ContainerRegistryPullOnly"]' 'module.eks.module.karpenter.aws_iam_role_policy_attachment.node["AmazonEC2ContainerRegistryPullOnly"]'
run_cmd terraform state mv 'module.karpenter.aws_iam_role_policy_attachment.node["AmazonEKSWorkerNodePolicy"]' 'module.eks.module.karpenter.aws_iam_role_policy_attachment.node["AmazonEKSWorkerNodePolicy"]'
run_cmd terraform state mv 'module.karpenter.aws_iam_role_policy_attachment.node["AmazonEKS_CNI_Policy"]' 'module.eks.module.karpenter.aws_iam_role_policy_attachment.node["AmazonEKS_CNI_Policy"]'
run_cmd terraform state mv 'module.karpenter.aws_iam_role_policy_attachment.node_additional["AmazonSSMManagedInstanceCore"]' 'module.eks.module.karpenter.aws_iam_role_policy_attachment.node_additional["AmazonSSMManagedInstanceCore"]'
run_cmd terraform state mv 'module.karpenter.aws_sqs_queue.this[0]' 'module.eks.module.karpenter.aws_sqs_queue.this[0]'
run_cmd terraform state mv 'module.karpenter.aws_sqs_queue_policy.this[0]' 'module.eks.module.karpenter.aws_sqs_queue_policy.this[0]'

# Secrets manager
run_cmd terraform state mv 'module.secrets_manager_json.aws_secretsmanager_secret.this[0]' 'module.eks.module.secrets_manager_json.aws_secretsmanager_secret.this[0]'
run_cmd terraform state mv 'module.secrets_manager_json.aws_secretsmanager_secret_version.this[0]' 'module.eks.module.secrets_manager_json.aws_secretsmanager_secret_version.this[0]'

echo ""
echo "=== Migration complete ==="
echo "Run 'terraform plan' to verify no changes are needed."
