resource "aws_cloudfront_origin_access_identity" "frontend_www_redirect" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  comment = "${local.project_name} frontend www redirect"
}

resource "aws_cloudfront_distribution" "frontend_www_redirect" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  origin {
    domain_name = element(aws_s3_bucket.frontend_www_redirect.*.website_endpoint, 0)
    origin_id   = "${local.project_name}-www-redirect"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled = true
  aliases = [
    local.site_url
  ]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.project_name}-www-redirect"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
    compress    = true

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.cloudfront_tls_certificate_arn == "" ? aws_acm_certificate.cloudfront_frontend.0.arn : local.cloudfront_tls_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  is_ipv6_enabled = local.cloudfront_enable_ipv6

  web_acl_id = local.cloudfront_enable_waf ? element(aws_wafv2_web_acl.cloudfront_waf.*.arn, 0) : null

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "cloudfront/frontend-www-redirect/"
  }

  depends_on = [
    aws_acm_certificate_validation.cloudfront_frontend
  ]
}
