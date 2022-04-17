resource "aws_route53_record" "cloudfront_frontend_tls_certificate_dns_validation" {
  for_each = local.cloudfront_tls_certificate_arn == "" ? (
    local.route53_hosted_zone_options.create_certificate_dns_validation_records ? {
      for dvo in aws_acm_certificate.cloudfront_frontend.0.domain_validation_options : dvo.domain_name => {
        name   = dvo.resource_record_name
        record = dvo.resource_record_value
        type   = dvo.resource_record_type
      }
    } : null
  ) : null

  zone_id = data.aws_route53_zone.default.0.zone_id
  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
  ttl     = "86400"
}

resource "aws_route53_record" "frontend" {
  count = local.route53_hosted_zone_options.create_site_url_dns_records ? 1 : 0

  zone_id = data.aws_route53_zone.default.0.zone_id
  name    = local.cloudfront_enable_apex_to_www_redirect ? "www.${local.site_url}" : local.site_url
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "frontend_www_redirect" {
  count = local.route53_hosted_zone_options.create_site_url_dns_records ? (
    local.cloudfront_enable_apex_to_www_redirect ? 1 : 0
  ) : 0

  zone_id = data.aws_route53_zone.default.0.zone_id
  name    = local.site_url
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_www_redirect.0.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_www_redirect.0.hosted_zone_id
    evaluate_target_health = true
  }
}
