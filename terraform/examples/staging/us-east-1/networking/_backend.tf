// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  backend "s3" {
    bucket       = "ksk-gbl-infra-bootstrap-state"
    key          = "terraform/examples/staging/us-east-1/networking.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
