locals {
  site_url                               = var.site_url
  project_random_id                      = random_id.project.dec
  project_name                           = "${replace(local.site_url, ".", "-")}-${local.project_random_id}"
  cloudfront_tls_certificate_arn         = var.cloudfront_tls_certificate_arn
  cloudfront_enable_ipv6                 = var.cloudfront_enable_ipv6
  cloudfront_enable_waf                  = var.cloudfront_enable_waf
  cloudfront_enable_apex_to_www_redirect = var.cloudfront_enable_apex_to_www_redirect
}
