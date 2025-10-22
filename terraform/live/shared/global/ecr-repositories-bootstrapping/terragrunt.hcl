include "root" {
  # This handles the dynamic backend setup
  path = find_in_parent_folders("root.hcl")
  expose = true
}

include "environment" {
  path = find_in_parent_folders("environment.hcl")
}

# NOTE: We manually set the outputs of the terraform-bootstrapping unit to
#       simplify cross account state referencing before our necessary IAM is in place
#       this requires a one time manual apply + pasting of ARNs per AWS account.
#       An alternative approach would be to provision the necessary IAM role in the target
#       account (e.g. via control tower)
inputs = {
  # BOOTSTRAP: Set to the arn of the manually created role (which will get imported)
  terraform_iam_role_arn = "arn:aws:iam::857059614049:role/ksk-gbl-ecr-bootstrap-admin"
  stage = "ecr"
  name = "bootstrap"
}
