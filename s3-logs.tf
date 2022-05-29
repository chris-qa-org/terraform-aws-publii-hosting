resource "aws_s3_bucket" "logs" {
  bucket        = "${local.project_name}-logs"
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# If default encryption is enabled on the target bucket, AES256 (SSE-S3) must be selected as the encryption key
# https://aws.amazon.com/premiumsupport/knowledge-center/s3-server-access-log-not-delivered/
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "template_file" "logs_bucket_enforce_tls_statement" {
  template = file("${path.module}/policies/s3-bucket-policy-statements/enforce-tls.json.tpl")

  vars = {
    bucket_arn = aws_s3_bucket.logs.arn
  }
}

data "template_file" "logs_bucket_log_delivery_access_statement" {
  template = file("${path.module}/policies/s3-bucket-policy-statements/log-delivery-access.json.tpl")

  vars = {
    log_bucket_arn = aws_s3_bucket.logs.arn
    source_bucket_arns = local.cloudfront_enable_apex_to_www_redirect ? jsonencode([
      aws_s3_bucket.frontend.arn,
      aws_s3_bucket.frontend_www_redirect.0.arn,
      ]) : jsonencode([
      aws_s3_bucket.frontend.arn,
    ])
    account_id = local.account_id
  }
}

data "template_file" "logs_bucket_policy" {
  template = file("${path.module}/policies/s3-bucket-policy.json.tpl")

  vars = {
    statement = <<EOT
[
${data.template_file.logs_bucket_enforce_tls_statement.rendered},
${data.template_file.logs_bucket_log_delivery_access_statement.rendered}
]
EOT
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.template_file.logs_bucket_policy.rendered
}
