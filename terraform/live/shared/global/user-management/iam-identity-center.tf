# IAM Identity Center
# 1. User creation
# 2. Group assignment
module "aws-iam-identity-center" {
  source  = "aws-ia/iam-identity-center/aws"
  version = "1.0.4"

  # Loaded from data/users.yaml in locals.tf
  # Managed separately a because:
  # 1. Will be updated much more frequently than groups/permission sets
  # 2. The users file serves as a single source of truth for github and aws access
  sso_users = local.sso_users

  sso_groups = {
    Admin : {
      group_name        = "Admin"
      group_description = "Admin IAM Identity Center Group"
    },
    PowerUser : {
      group_name        = "PowerUser"
      group_description = "PowerUser IAM Identity Center Group"
    },
    ReadOnly : {
      group_name        = "ReadOnly"
      group_description = "ReadOnly IAM Identity Center Group"
    },
  }

  permission_sets = {
    AdministratorAccess = {
      description          = "Provides AWS full access permissions.",
      session_duration     = "PT12H",
      aws_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      tags                 = { ManagedBy = "Terraform" }
    },
    PowerUserAccess = {
      description          = "Provides AWS Power User permissions.",
      session_duration     = "PT12H",
      aws_managed_policies = ["arn:aws:iam::aws:policy/PowerUserAccess"]
      tags                 = { ManagedBy = "Terraform" }
    },
    ViewOnlyAccess = {
      description          = "Provides AWS view only permissions.",
      session_duration     = "PT12H",
      aws_managed_policies = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
      tags                 = { ManagedBy = "Terraform" }
    },
  }

  account_assignments = {
    Admin : {
      principal_name = "Admin"
      principal_type = "GROUP"
      principal_idp  = "INTERNAL"
      # permission_sets = ["AdministratorAccess", "PowerUserAccess", "ViewOnlyAccess"]
      permission_sets = ["AdministratorAccess"]
      account_ids     = local.account_ids
    },
    ReadOnly : {
      principal_name  = "ReadOnly"
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL"
      permission_sets = ["ViewOnlyAccess"]
      account_ids     = local.account_ids
    },
  }

}

