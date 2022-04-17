resource "aws_acm_certificate" "cloudfront_frontend" {
  provider = aws.useast1

  count = local.cloudfront_tls_certificate_arn == "" ? 1 : 0

  domain_name = local.site_url
  subject_alternative_names = local.cloudfront_enable_apex_to_www_redirect ? [
    "www.${local.site_url}"
  ] : []

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

