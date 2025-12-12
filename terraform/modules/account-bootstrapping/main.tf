module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.2.1"

  name            = "${module.this.id}-admin"
  use_name_prefix = false

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = ["sts:AssumeRole"]
      principals = [
        {
          type = "AWS"
          identifiers = [
            var.github_oidc_assume_role_arn,
            var.sso_admin_assume_role_arn
          ]
        }
      ]
    }
  }

  policies = { AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess" }
}

module "zone" {
  count   = var.create_zone ? 1 : 0
  source  = "terraform-aws-modules/route53/aws"
  version = "6.1.0"

  name = var.zone_name

  # Enables external-dns to update records
  # Without this, it will create a record initially, but will not update/delete
  records = var.zone_external_dns_owner != null ? {
    _extdns = {
      type = "TXT"
      ttl  = 300
      records = ["heritage=external-dns,external-dns/owner=${var.zone_external_dns_owner}"]
    }
  } : {}
}
