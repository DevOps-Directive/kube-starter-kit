#!/bin/bash
# State migration script for staging/us-east-2/services/go-backend
# Migrates state from root-level modules to module.go_backend.* prefix
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

echo "=== State Migration: staging/us-east-2/services/go-backend ==="
echo "Moving resources from root level to module.go_backend.*"
echo ""

# Root-level IAM policy
run_cmd terraform state mv 'aws_iam_policy.s3_access' 'module.go_backend.aws_iam_policy.s3_access'

# Pod identity module
run_cmd terraform state mv 'module.pod_identity.aws_eks_pod_identity_association.this["this"]' 'module.go_backend.module.pod_identity.aws_eks_pod_identity_association.this["this"]'
run_cmd terraform state mv 'module.pod_identity.aws_iam_role.this[0]' 'module.go_backend.module.pod_identity.aws_iam_role.this[0]'
run_cmd terraform state mv 'module.pod_identity.aws_iam_role_policy_attachment.this["S3Access"]' 'module.go_backend.module.pod_identity.aws_iam_role_policy_attachment.this["S3Access"]'

# S3 bucket module
run_cmd terraform state mv 'module.s3_bucket.aws_s3_bucket.this[0]' 'module.go_backend.module.s3_bucket.aws_s3_bucket.this[0]'
run_cmd terraform state mv 'module.s3_bucket.aws_s3_bucket_public_access_block.this[0]' 'module.go_backend.module.s3_bucket.aws_s3_bucket_public_access_block.this[0]'
run_cmd terraform state mv 'module.s3_bucket.aws_s3_bucket_versioning.this[0]' 'module.go_backend.module.s3_bucket.aws_s3_bucket_versioning.this[0]'

echo ""
echo "=== Migration complete ==="
echo "Run 'terraform plan' to verify no changes are needed."
