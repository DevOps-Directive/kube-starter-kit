# Import the existing IAM identity center user (used during initial bootstrapping)
# import {
#   to = module.aws-iam-identity-center.aws_identitystore_user.sso_users["sid@devopsdirective.com"]
#   id = "d-9a676f52a0/41bb8550-e071-70f9-571a-90fa0bfe5241"
# }


################

# Only necessary if these already exist
# import {
#   to = module.aws-iam-identity-center.aws_identitystore_group.sso_groups["admin"]
#   id = "d-9a676f52a0/911b55c0-80c1-7034-a78c-3e639985b062"
# }
# import {
#   to = module.aws-iam-identity-center.aws_identitystore_group.sso_groups["read-only"]
#   id = "d-9a676f52a0/51fbc560-0011-70d3-e81d-bbddd42b420f"
# }
#
# Had to retrieve membership id with:
# `aws identitystore get-group-membership-id --identity-store-id d-9a676f52a0 --group-id 911b55c0-80c1-7034-a78c-3e639985b062 --member-id UserId=41bb8550-e071-70f9-571a-90fa0bfe5241`
# import {
#   to = module.aws-iam-identity-center.aws_identitystore_group_membership.sso_group_membership["sid@devopsdirective.com_admin"]
#   id = "d-9a676f52a0/616b0560-8041-706b-0e6d-f8d26d4707b2"
# }
#
# import {
#   to = module.aws-iam-identity-center.aws_identitystore_group_membership.sso_group_membership["sid@devopsdirective.com_read-only"]
#   id = "d-9a676f52a0/819be580-90b1-7096-3427-5e9148968598"
# }
#
