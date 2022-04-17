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

resource "aws_acm_certificate_validation" "cloudfront_frontend" {
  provider = aws.useast1

  count = local.cloudfront_tls_certificate_arn == "" ? (
    local.route53_hosted_zone_options.create_certificate_dns_validation_records ? 1 : 0
  ) : 0

  certificate_arn         = aws_acm_certificate.cloudfront_frontend.0.arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_frontend_tls_certificate_dns_validation : record.fqdn]
}

