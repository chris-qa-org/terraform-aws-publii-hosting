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
