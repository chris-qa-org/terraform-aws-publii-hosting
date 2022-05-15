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
  aliases = local.cloudfront_enable_apex_to_www_redirect ? [
    "www.${local.site_url}"
    ] : [
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

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.frontend_viewer_request.arn
    }
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

  ## borrowed/copied from https://github.com/terraform-aws-modules/terraform-aws-cloudfront/blob/master/main.tf
  dynamic "ordered_cache_behavior" {
    for_each = local.cloudfront_ordered_cache_behaviors
    iterator = i

    content {
      path_pattern           = i.value["path_pattern"]
      target_origin_id       = i.value["target_origin_id"]
      viewer_protocol_policy = i.value["viewer_protocol_policy"]

      allowed_methods           = lookup(i.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods            = lookup(i.value, "cached_methods", ["GET", "HEAD"])
      compress                  = lookup(i.value, "compress", null)
      field_level_encryption_id = lookup(i.value, "field_level_encryption_id", null)
      smooth_streaming          = lookup(i.value, "smooth_streaming", null)
      trusted_signers           = lookup(i.value, "trusted_signers", null)
      trusted_key_groups        = lookup(i.value, "trusted_key_groups", null)

      cache_policy_id            = lookup(i.value, "cache_policy_id", null)
      origin_request_policy_id   = lookup(i.value, "origin_request_policy_id", null)
      response_headers_policy_id = lookup(i.value, "response_headers_policy_id", null)
      realtime_log_config_arn    = lookup(i.value, "realtime_log_config_arn", null)

      min_ttl     = lookup(i.value, "min_ttl", null)
      default_ttl = lookup(i.value, "default_ttl", null)
      max_ttl     = lookup(i.value, "max_ttl", null)

      dynamic "forwarded_values" {
        for_each = lookup(i.value, "use_forwarded_values", true) ? [true] : []

        content {
          query_string            = lookup(i.value, "query_string", false)
          query_string_cache_keys = lookup(i.value, "query_string_cache_keys", [])
          headers                 = lookup(i.value, "headers", [])

          cookies {
            forward           = lookup(i.value, "cookies_forward", "none")
            whitelisted_names = lookup(i.value, "cookies_whitelisted_names", null)
          }
        }
      }

      dynamic "lambda_function_association" {
        for_each = lookup(i.value, "lambda_function_association", [])
        iterator = l

        content {
          event_type   = l.key
          lambda_arn   = l.value.lambda_arn
          include_body = lookup(l.value, "include_body", null)
        }
      }

      dynamic "function_association" {
        for_each = lookup(i.value, "function_association", [])
        iterator = f

        content {
          event_type   = f.key
          function_arn = f.value.function_arn
        }
      }
    }
  }
  ##

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
    prefix          = "cloudfront/frontend/"
  }

  depends_on = [
    aws_acm_certificate_validation.cloudfront_frontend
  ]
}
