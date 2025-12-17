// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  backend "s3" {
    bucket       = "ksk-gbl-infra-bootstrap-state"
    key          = "terraform/live/shared/global/terraform-bootstrapping.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
