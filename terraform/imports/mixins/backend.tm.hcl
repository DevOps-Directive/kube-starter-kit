# Generate S3 backend configuration for all stacks
generate_hcl "_backend.tf" {
  content {
    terraform {
      backend "s3" {
        bucket       = global.backend_bucket
        key          = "${terramate.stack.path.relative}.tfstate"
        region       = global.backend_region
        use_lockfile = true
      }
    }
  }
}
