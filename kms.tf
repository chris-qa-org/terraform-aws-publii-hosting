resource "aws_kms_key" "s3_bucket_frontend_www_redirect" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  description             = "This key is used to encrypt bucket objects within ${element(aws_s3_bucket.frontend_www_redirect.*.id, 0)}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}
