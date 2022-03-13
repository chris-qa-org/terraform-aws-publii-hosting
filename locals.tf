locals {
  site_url                       = var.site_url
  project_random_id              = random_id.project.dec
  project_name                   = "${replace(local.site_url, ".", "-")}-${local.project_random_id}"
  cloudfront_tls_certificate_arn = var.cloudfront_tls_certificate_arn
  cloudfront_enable_ipv6         = var.cloudfront_enable_ipv6
}
