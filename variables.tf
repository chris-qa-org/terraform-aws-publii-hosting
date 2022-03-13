variable "site_url" {
  description = "The desired site URL"
  type        = string
}

variable "s3_bucket_acl" {
  description = "S3 bucket ACL"
  default     = "private"
  type        = string
}
