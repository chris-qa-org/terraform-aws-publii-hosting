variable "site_url" {
  description = "The desired site URL"
  type        = string
}

variable "s3_bucket_acl" {
  description = "S3 bucket ACL"
  default     = "private"
  type        = string
}

variable "cloudfront_tls_certificate_arn" {
  description = "CloudFront TLS certificate ARN (must be created in us-east-1 region)"
  type        = string
  default     = ""
}

variable "cloudfront_enable_ipv6" {
  description = "Enable IPv6 on CloudFront"
  type        = bool
  default     = true
}

variable "cloudfront_enable_waf" {
  description = "Enable CloudFront WAF"
  type        = bool
  default     = true
}

variable "cloudfront_enable_apex_to_www_redirect" {
  description = "Enable CloudFront apex to www redirect"
  type        = bool
  default     = true
}

variable "enable_publii_pretty_urls" {
  description = "If you hae enabled 'Pretty URLs' in Publii, set this to true"
  type        = bool
  default     = false
}

variable "route53_hosted_zone_options" {
  description = "If you have a Route53 zone, the required DNS records can be created automatically."
  type = object({
    id                                        = string
    create_certificate_dns_validation_records = bool
    create_site_url_dns_records               = bool
  })
  default = {
    id                                        = ""
    create_certificate_dns_validation_records = false
    create_site_url_dns_records               = false
  }
}
