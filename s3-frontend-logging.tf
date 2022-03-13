resource "aws_s3_bucket" "frontend_logging" {
  bucket        = "frontend-${local.project_name}-logs"
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "frontend_logging" {
  bucket = aws_s3_bucket.frontend_logging.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "frontend_logging" {
  bucket = aws_s3_bucket.frontend_logging.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "frontend_logging" {
  bucket                  = aws_s3_bucket.frontend_logging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_logging" {
  bucket = aws_s3_bucket.frontend_logging.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_bucket_frontend_logging.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

data "template_file" "frontend_logging_bucket_enforce_tls_statement" {
  template = file("${path.module}/policies/s3-bucket-policy-statements/enforce-tls.json.tpl")

  vars = {
    bucket_arn = aws_s3_bucket.frontend_logging.arn
  }
}

data "template_file" "frontend_logging_bucket_policy" {
  template = file("${path.module}/policies/s3-bucket-policy.json.tpl")

  vars = {
    statement = <<EOT
[
${data.template_file.frontend_logging_bucket_enforce_tls_statement.rendered}
]
EOT
  }
}

resource "aws_s3_bucket_policy" "frontend_logging" {
  bucket = aws_s3_bucket.frontend_logging.id
  policy = data.template_file.frontend_logging_bucket_policy.rendered
}
