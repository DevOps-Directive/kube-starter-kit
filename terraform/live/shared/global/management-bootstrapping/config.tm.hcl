# Stack-specific configuration
# Override stage to match the IAM role name (ksk-gbl-mgmt-bootstrap-admin)
globals {
  stage = "mgmt"
}

globals "bootstrapping" {
  aws_region              = "us-east-2"
  create_zone             = false
  zone_name               = null
  zone_external_dns_owner = null
}
