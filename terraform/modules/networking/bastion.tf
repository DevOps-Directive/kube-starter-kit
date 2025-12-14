# Bastion host for private resource access via AWS SSM Session Manager
#
# This bastion can be used as a SOCKS proxy for accessing private resources like:
# - Private EKS API endpoints
# - Private RDS instances
# - Other VPC-internal services
#
# Usage: ssh -ND <port> ec2-user@<instance-id> (via SSM SSH proxy)

###############################################################################
# SSM VPC Endpoints (required for private bastion without public IP)
###############################################################################

resource "aws_security_group" "ssm_endpoints" {
  count = var.enable_bastion ? 1 : 0

  name        = "${module.this.id}-ssm-endpoints"
  description = "Security group for SSM VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "HTTPS from VPC"
  }

  tags = merge(module.this.tags, {
    Name = "${module.this.id}-ssm-endpoints"
  })
}

module "ssm_endpoints" {
  count = var.enable_bastion ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "6.5.1"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.ssm_endpoints[0].id]

  endpoints = {
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${module.this.id}-ssm" }
    }
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${module.this.id}-ssmmessages" }
    }
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${module.this.id}-ec2messages" }
    }
  }

  tags = module.this.tags
}

###############################################################################
# Bastion Host
###############################################################################

# Latest Amazon Linux 2023 AMI for ARM64/Graviton (has SSM agent pre-installed)
data "aws_ami" "amazon_linux_2023" {
  count = var.enable_bastion ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "bastion" {
  count = var.enable_bastion ? 1 : 0

  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.1.5"

  name = "${module.this.id}-bastion"

  ami           = data.aws_ami.amazon_linux_2023[0].id
  instance_type = var.bastion_instance_type
  subnet_id     = module.vpc.private_subnets[0]

  # No SSH key needed - access is via SSM only
  # No public IP needed - SSM uses VPC endpoints

  # IAM role for SSM access
  create_iam_instance_profile = true
  iam_role_name               = "${module.this.id}-bastion"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # Security group - all traffic stays within VPC
  vpc_security_group_ids = [aws_security_group.bastion[0].id]

  # IMDSv2 only (module defaults to http_tokens = "required")

  # Encrypted root volume (v6 uses object, not list; size/type instead of volume_size/volume_type)
  # AL2023 AMI requires minimum 30GB
  root_block_device = {
    size      = 30
    type      = "gp3"
    encrypted = true
  }

  tags = module.this.tags

  depends_on = [module.ssm_endpoints]
}

# Security group - all traffic stays within VPC (SSM via endpoints, proxy to private resources)
resource "aws_security_group" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name        = "${module.this.id}-bastion"
  description = "Security group for bastion host (SSM access only)"
  vpc_id      = module.vpc.vpc_id

  # All outbound to VPC (SSM endpoints + proxy to private resources)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "All traffic to VPC (SSM endpoints + proxy)"
  }

  tags = merge(module.this.tags, {
    Name = "${module.this.id}-bastion"
  })
}
