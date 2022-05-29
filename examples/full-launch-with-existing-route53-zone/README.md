# Full launch with existing Route53 Zone 

 - [main.tf](./main.tf)

```
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
  version = "v1.1.0"

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
}
```
