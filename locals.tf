locals {
  account_id                             = data.aws_caller_identity.current.account_id
  site_url                               = var.site_url
  project_random_id                      = random_id.project.dec
  project_name                           = "${replace(local.site_url, ".", "-")}-${local.project_random_id}"
  cloudfront_tls_certificate_arn         = var.cloudfront_tls_certificate_arn
  cloudfront_enable_ipv6                 = var.cloudfront_enable_ipv6
  cloudfront_enable_waf                  = var.cloudfront_enable_waf
  cloudfront_enable_apex_to_www_redirect = var.cloudfront_enable_apex_to_www_redirect
  enable_publii_pretty_urls              = var.enable_publii_pretty_urls
  route53_hosted_zone_options            = var.route53_hosted_zone_options
  cloudfront_ordered_cache_behaviors     = var.cloudfront_ordered_cache_behaviors
  cloudfront_origins                     = var.cloudfront_origins
}
