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
