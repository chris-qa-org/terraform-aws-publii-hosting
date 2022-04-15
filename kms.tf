resource "aws_kms_key" "s3_bucket_frontend" {
  description             = "This key is used to encrypt bucket objects within ${aws_s3_bucket.frontend.id}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_key" "logs" {
  description             = "This key is used to encrypt bucket objects within ${aws_s3_bucket.logs.id}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}
