module "state-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket = "kube-starter-kit-tf-state"

  versioning = {
    enabled = true
  }
}

module "plans-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket = "kube-starter-kit-tf-digger-plans"

  versioning = {
    enabled = true
  }
}

