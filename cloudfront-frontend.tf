resource "aws_cloudfront_origin_access_identity" "frontend" {
  comment = "${local.project_name} frontend"
}

resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = local.project_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
    }
  }

  enabled = true
  aliases = [
    local.site_url
  ]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.project_name

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

  default_root_object = "index.html"

  custom_error_response {
    error_code         = "404"
    response_code      = "404"
    response_page_path = "/404.html"
  }

  custom_error_response {
    error_code         = "403"
    response_code      = "404"
    response_page_path = "/404.html"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.cloudfront_tls_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  is_ipv6_enabled = local.cloudfront_enable_ipv6

  web_acl_id = local.cloudfront_enable_waf ? element(aws_wafv2_web_acl.cloudfront_waf.*.arn, 0) : null

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "cloudfront/frontend/"
  }
}
