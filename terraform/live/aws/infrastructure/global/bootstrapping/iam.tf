# The only thing the OIDC role can do is assume the chain role
module "github-oidc-provider" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "2.2.1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = ["DevOps-Directive/kube-starter-kit"]
  oidc_role_attach_policies = [module.iam_policy.arn]
}

module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.2.1"

  name            = "github-oidc-provider-aws-chain"
  use_name_prefix = false

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = ["sts:AssumeRole"]
      principals = [
        {
          type = "AWS"
          identifiers = [
            "arn:aws:iam::094905625236:role/github-oidc-provider-aws",                                                                       # TODO: look up from remote state
            "arn:aws:iam::094905625236:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AWSAdministratorAccess_fa7ea65862c3f54a" # TODO: establish better way to look this up
          ]
        }
      ]
    }
  }

  policies = { AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess" }

  tags = {
    AllowGithubOIDCChain = "true"
  }
}

module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "6.2.1"

  name_prefix = "allow-github-oidc-role-assumptions"
  path        = "/"
  description = "My example policy"

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AssumeOnlyTaggedChainRoles",
          "Effect": "Allow",
          "Action": [
            "sts:AssumeRole",
            "sts:TagSession"
          ],
          "Resource": "arn:aws:iam::*:role/github-oidc-provider-aws-chain",
          "Condition": {
            "StringEquals": {
              "iam:ResourceTag/AllowGithubOIDCChain": "true"
            }
          }
        }
      ]
    }
  EOF
}
