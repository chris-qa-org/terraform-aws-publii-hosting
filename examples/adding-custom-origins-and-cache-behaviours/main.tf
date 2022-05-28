provider "aws" {
  region = "us-east-1"
  alias  = "useast1"
  default_tags {
    tags = {
      Project = "my-project"
    }
  }
}

resource "aws_route53_zone" "example" {
  name = "example.com"
}

module "aws_publii_hosting" {
  source  = "chris-qa-org/publii-hosting/aws"
  version = "v1.0.1"

  providers = {
    aws.useast1 = aws.useast1
  }

  site_url                               = "example.com"
  s3_bucket_acl                          = "private"
  cloudfront_enable_ipv6                 = true
  cloudfront_enable_waf                  = true // Note: This will cost at least $5.00/month - https://aws.amazon.com/waf/pricing/ (default: false)
  cloudfront_enable_apex_to_www_redirect = true
  enable_publii_pretty_urls              = true
  route53_hosted_zone_options = {
    id                                        = aws_route53_zone.example.id
    create_certificate_dns_validation_records = true
    create_site_url_dns_records               = true
  }

  cloudfront_origins = [
    {
      domain_name = aws_s3_bucket.example.bucket_regional_domain_name
      origin_id   = "example-custom-origin"

      s3_origin_config = {
        origin_access_identity = aws_cloudfront_origin_access_identity.example.cloudfront_access_identity_path
      }
    }
  ]

  cloudfront_ordered_cache_behaviors = [
    {
      path_pattern     = "/example/*"
      allowed_methods  = ["GET", "HEAD"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "example-custom-origin"

      use_forwarded_values = true
      query_string = false
      headers = ["Origin"]
      cookies_forward = "none"

      min_ttl                = 0
      default_ttl            = 86400
      max_ttl                = 31536000
      compress               = true
      viewer_protocol_policy = "redirect-to-https"
    }
  ]
}
