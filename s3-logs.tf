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

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.logs.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

data "template_file" "logs_bucket_enforce_tls_statement" {
  template = file("${path.module}/policies/s3-bucket-policy-statements/enforce-tls.json.tpl")

  vars = {
    bucket_arn = aws_s3_bucket.logs.arn
  }
}

data "template_file" "logs_bucket_policy" {
  template = file("${path.module}/policies/s3-bucket-policy.json.tpl")

  vars = {
    statement = <<EOT
[
${data.template_file.logs_bucket_enforce_tls_statement.rendered}
]
EOT
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.template_file.logs_bucket_policy.rendered
}
