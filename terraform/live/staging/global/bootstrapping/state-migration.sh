#!/bin/bash
# State migration script for staging/global/bootstrapping
# Migrates state from root-level modules to module.bootstrapping.* prefix
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

echo "=== State Migration: staging/global/bootstrapping ==="
echo "Moving resources from root level to module.bootstrapping.*"
echo ""

# IAM role resources
run_cmd terraform state mv 'module.iam_role.aws_iam_role.this[0]' 'module.bootstrapping.module.iam_role.aws_iam_role.this[0]'
run_cmd terraform state mv 'module.iam_role.aws_iam_role_policy_attachment.this["AdministratorAccess"]' 'module.bootstrapping.module.iam_role.aws_iam_role_policy_attachment.this["AdministratorAccess"]'

# Route53 zone resources
run_cmd terraform state mv 'module.zone[0].aws_route53_zone.this[0]' 'module.bootstrapping.module.zone[0].aws_route53_zone.this[0]'
run_cmd terraform state mv 'module.zone[0].aws_route53_record.this["_extdns"]' 'module.bootstrapping.module.zone[0].aws_route53_record.this["_extdns"]'

echo ""
echo "=== Migration complete ==="
echo "Run 'terraform plan' to verify no changes are needed."
