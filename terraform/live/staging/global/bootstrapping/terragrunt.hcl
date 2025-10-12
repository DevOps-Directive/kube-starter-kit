include "root" {
  # This handles the dynamic backend setup
  path = find_in_parent_folders("root.hcl")
  expose = true
}

# NOTE: We manually set the outputs of the terraform-bootstrapping unit to
#       simplify cross account state referencing before our necessary IAM is in place
#       this requires a one time manual apply + pasting of ARNs per AWS account.
#       An alternative approach would be to provision the necessary IAM role in the target
#       account (e.g. via control tower)
inputs = {
  github_oidc_assume_role_arn = include.root.locals.github_oidc_assume_role_arn
  sso_admin_assume_role_arn = include.root.locals.github_oidc_assume_role_arn
  terraform_iam_role_arn = "arn:aws:iam::038198578795:role/github-oidc-provider-aws-chain" # BOOTSTRAP: Set to the arn of the role that gets created
}