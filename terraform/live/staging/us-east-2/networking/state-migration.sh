#!/bin/bash
# State migration script for staging/us-east-2/networking
# Migrates state from root-level modules to module.networking.* prefix
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

echo "=== State Migration: staging/us-east-2/networking ==="
echo "Moving resources from root level to module.networking.*"
echo ""

# Root-level data sources (these will be recreated, no need to migrate)
# data.aws_ami.amazon_linux_2023[0]
# data.aws_availability_zones.available

# Root-level security groups
run_cmd terraform state mv 'aws_security_group.bastion[0]' 'module.networking.aws_security_group.bastion[0]'
run_cmd terraform state mv 'aws_security_group.ssm_endpoints[0]' 'module.networking.aws_security_group.ssm_endpoints[0]'

# VPC module
run_cmd terraform state mv 'module.vpc.aws_vpc.this[0]' 'module.networking.module.vpc.aws_vpc.this[0]'
run_cmd terraform state mv 'module.vpc.aws_internet_gateway.this[0]' 'module.networking.module.vpc.aws_internet_gateway.this[0]'
run_cmd terraform state mv 'module.vpc.aws_default_network_acl.this[0]' 'module.networking.module.vpc.aws_default_network_acl.this[0]'
run_cmd terraform state mv 'module.vpc.aws_default_route_table.default[0]' 'module.networking.module.vpc.aws_default_route_table.default[0]'
run_cmd terraform state mv 'module.vpc.aws_default_security_group.this[0]' 'module.networking.module.vpc.aws_default_security_group.this[0]'
run_cmd terraform state mv 'module.vpc.aws_route.public_internet_gateway[0]' 'module.networking.module.vpc.aws_route.public_internet_gateway[0]'

# VPC subnets
for i in 0 1 2; do
  run_cmd terraform state mv "module.vpc.aws_subnet.private[$i]" "module.networking.module.vpc.aws_subnet.private[$i]"
  run_cmd terraform state mv "module.vpc.aws_subnet.public[$i]" "module.networking.module.vpc.aws_subnet.public[$i]"
done

# VPC route tables
run_cmd terraform state mv 'module.vpc.aws_route_table.public[0]' 'module.networking.module.vpc.aws_route_table.public[0]'
for i in 0 1 2; do
  run_cmd terraform state mv "module.vpc.aws_route_table.private[$i]" "module.networking.module.vpc.aws_route_table.private[$i]"
  run_cmd terraform state mv "module.vpc.aws_route_table_association.private[$i]" "module.networking.module.vpc.aws_route_table_association.private[$i]"
  run_cmd terraform state mv "module.vpc.aws_route_table_association.public[$i]" "module.networking.module.vpc.aws_route_table_association.public[$i]"
done

# Bastion module
run_cmd terraform state mv 'module.bastion[0].aws_iam_role.this[0]' 'module.networking.module.bastion[0].aws_iam_role.this[0]'
run_cmd terraform state mv 'module.bastion[0].aws_iam_instance_profile.this[0]' 'module.networking.module.bastion[0].aws_iam_instance_profile.this[0]'
run_cmd terraform state mv 'module.bastion[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedInstanceCore"]' 'module.networking.module.bastion[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedInstanceCore"]'
run_cmd terraform state mv 'module.bastion[0].aws_iam_role_policy_attachment.this["EC2InstanceConnect"]' 'module.networking.module.bastion[0].aws_iam_role_policy_attachment.this["EC2InstanceConnect"]'
run_cmd terraform state mv 'module.bastion[0].aws_instance.this[0]' 'module.networking.module.bastion[0].aws_instance.this[0]'
run_cmd terraform state mv 'module.bastion[0].aws_security_group.this[0]' 'module.networking.module.bastion[0].aws_security_group.this[0]'
run_cmd terraform state mv 'module.bastion[0].aws_vpc_security_group_egress_rule.this["ipv4_default"]' 'module.networking.module.bastion[0].aws_vpc_security_group_egress_rule.this["ipv4_default"]'
run_cmd terraform state mv 'module.bastion[0].aws_vpc_security_group_egress_rule.this["ipv6_default"]' 'module.networking.module.bastion[0].aws_vpc_security_group_egress_rule.this["ipv6_default"]'

# FCK-NAT modules (3 instances)
for i in 0 1 2; do
  run_cmd terraform state mv "module.fck-nat[$i].aws_autoscaling_group.main[0]" "module.networking.module.fck-nat[$i].aws_autoscaling_group.main[0]"
  run_cmd terraform state mv "module.fck-nat[$i].aws_iam_instance_profile.main" "module.networking.module.fck-nat[$i].aws_iam_instance_profile.main"
  run_cmd terraform state mv "module.fck-nat[$i].aws_iam_policy.main" "module.networking.module.fck-nat[$i].aws_iam_policy.main"
  run_cmd terraform state mv "module.fck-nat[$i].aws_iam_role.main" "module.networking.module.fck-nat[$i].aws_iam_role.main"
  run_cmd terraform state mv "module.fck-nat[$i].aws_iam_role_policy_attachment.main" "module.networking.module.fck-nat[$i].aws_iam_role_policy_attachment.main"
  run_cmd terraform state mv "module.fck-nat[$i].aws_launch_template.main" "module.networking.module.fck-nat[$i].aws_launch_template.main"
  run_cmd terraform state mv "module.fck-nat[$i].aws_network_interface.main" "module.networking.module.fck-nat[$i].aws_network_interface.main"
  run_cmd terraform state mv "module.fck-nat[$i].aws_route.main[\"private\"]" "module.networking.module.fck-nat[$i].aws_route.main[\"private\"]"
  run_cmd terraform state mv "module.fck-nat[$i].aws_security_group.main" "module.networking.module.fck-nat[$i].aws_security_group.main"
done

# SSM endpoints module
run_cmd terraform state mv 'module.ssm_endpoints[0].aws_vpc_endpoint.this["ec2messages"]' 'module.networking.module.ssm_endpoints[0].aws_vpc_endpoint.this["ec2messages"]'
run_cmd terraform state mv 'module.ssm_endpoints[0].aws_vpc_endpoint.this["ssm"]' 'module.networking.module.ssm_endpoints[0].aws_vpc_endpoint.this["ssm"]'
run_cmd terraform state mv 'module.ssm_endpoints[0].aws_vpc_endpoint.this["ssmmessages"]' 'module.networking.module.ssm_endpoints[0].aws_vpc_endpoint.this["ssmmessages"]'

# PlanetScale VPC endpoint
run_cmd terraform state mv 'module.planetscale_vpce.aws_vpc_endpoint.this["planetscale"]' 'module.networking.module.planetscale_vpce.aws_vpc_endpoint.this["planetscale"]'

# PlanetScale security group
run_cmd terraform state mv 'module.planetscale_vpce_sg.module.sg.aws_security_group.this_name_prefix[0]' 'module.networking.module.planetscale_vpce_sg.module.sg.aws_security_group.this_name_prefix[0]'
run_cmd terraform state mv 'module.planetscale_vpce_sg.module.sg.aws_security_group_rule.egress_rules[0]' 'module.networking.module.planetscale_vpce_sg.module.sg.aws_security_group_rule.egress_rules[0]'
run_cmd terraform state mv 'module.planetscale_vpce_sg.module.sg.aws_security_group_rule.ingress_rules[0]' 'module.networking.module.planetscale_vpce_sg.module.sg.aws_security_group_rule.ingress_rules[0]'
run_cmd terraform state mv 'module.planetscale_vpce_sg.module.sg.aws_security_group_rule.ingress_with_self[0]' 'module.networking.module.planetscale_vpce_sg.module.sg.aws_security_group_rule.ingress_with_self[0]'

echo ""
echo "=== Migration complete ==="
echo "Run 'terraform plan' to verify no changes are needed."
