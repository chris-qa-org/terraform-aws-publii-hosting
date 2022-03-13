resource "aws_kms_key" "s3_bucket_frontend" {
  description             = "This key is used to encrypt bucket objects within ${aws_s3_bucket.frontend.id}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_key" "s3_bucket_frontend_logging" {
  description             = "This key is used to encrypt bucket objects within ${aws_s3_bucket.frontend_logging.id}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_key" "s3_bucket_cloudfront_frontend_logging" {
  description             = "This key is used to encrypt bucket objects within ${aws_s3_bucket.cloudfront_frontend_logging.id}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_key" "s3_bucket_cloudfront_frontend_logging_logging" {
  description             = "This key is used to encrypt bucket objects within ${aws_s3_bucket.cloudfront_frontend_logging_logging.id}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}
