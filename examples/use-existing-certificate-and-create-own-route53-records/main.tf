provider "aws" {
  region = "us-east-1"
  alias  = "useast1"
  default_tags {
    tags = {
      Project = "my-project"
    }
  }
}

module "aws_publii_hosting" {
  source  = "chris-qa-org/publii-hosting/aws"
  version = "v1.2.1"

  providers = {
    aws.useast1 = aws.useast1
  }

  site_url                               = "example.com"
  s3_bucket_acl                          = "private"
  cloudfront_tls_certificate_arn         = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  cloudfront_enable_ipv6                 = true
  cloudfront_enable_waf                  = true // Note: This will cost at least $5.00/month - https://aws.amazon.com/waf/pricing/ (default: false)
  cloudfront_enable_apex_to_www_redirect = true
  enable_publii_pretty_urls              = true
}

resource "aws_route53_zone" "example" {
  name = "example.com"
}

resource "aws_route53_record" "frontend" {
  zone_id = aws_route53_zone.example.zone_id
  name    = "www.example.com"
  type    = "A"

  alias {
    name                   = module.aws_publii_hosting.aws_cloudfront_distribution_frontend.domain_name
    zone_id                = module.aws_publii_hosting.aws_cloudfront_distribution_frontend.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "apex_redirect" {
  zone_id = aws_route53_zone.example.zone_id
  name    = "example.com"
  type    = "A"

  alias {
    name                   = module.aws_publii_hosting.aws_cloudfront_distribution_frontend_www_redirect.domain_name
    zone_id                = module.aws_publii_hosting.aws_cloudfront_distribution_frontend_www_redirect.hosted_zone_id
    evaluate_target_health = true
  }
}
