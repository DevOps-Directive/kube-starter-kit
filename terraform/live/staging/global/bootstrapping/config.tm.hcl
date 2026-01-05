# Stack-specific configuration
globals "bootstrapping" {
  aws_region              = "us-east-2"
  create_zone             = true
  zone_name               = "staging.kubestarterkit.com"
  zone_external_dns_owner = "external-dns"
}
