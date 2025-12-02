output "github_oidc_assume_role_arn" {
  value = module.github-oidc-provider.oidc_role
}

# TODO: avoid this magic string
# github oidc module doesn't allow modifying the trust policy (e.g. to assume from this role...)
# could create a separate role which can be assumed by the admin role (an additional hop)

output "sso_admin_assume_role_arn" {
  value = "arn:aws:iam::094905625236:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_80ecc41059967962"
}

output "tags" {
  value = module.label.tags
}
