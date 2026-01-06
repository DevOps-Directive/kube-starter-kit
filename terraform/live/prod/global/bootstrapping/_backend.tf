// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  backend "s3" {
    bucket       = "ksk-gbl-infra-bootstrap-state"
    key          = "terraform/live/prod/global/bootstrapping.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
