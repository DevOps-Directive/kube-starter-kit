# NOTE: We manually set the terraform_iam_role_arn unit to
#       simplify cross account state referencing before our necessary IAM is in place
#       this requires a one time manual apply + pasting of ARNs per AWS account.
#       An alternative approach would be to provision the necessary IAM role in the target
#       account (e.g. via control tower)
inputs = {
  # BOOTSTRAP: Set to the arn of the manually created role (which will get imported)
  terraform_iam_role_arn = "arn:aws:iam::038198578795:role/ksk-gbl-staging-bootstrap-admin"
  sso_admin_role_arn = "arn:aws:iam::038198578795:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AWSAdministratorAccess_bf4f5a0626f509cb"
  stage = "staging"
}