resource "aws_s3_bucket" "frontend_www_redirect" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  bucket        = "frontend-www-redirect-${local.project_name}"
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "frontend_www_redirect" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  bucket = aws_s3_bucket.frontend_www_redirect.0.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "frontend_www_redirect" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  bucket        = aws_s3_bucket.frontend_www_redirect.0.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3/frontend-www-redirect/"
}

resource "aws_s3_bucket_acl" "frontend_www_redirect" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  bucket = aws_s3_bucket.frontend_www_redirect.0.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "frontend_www_redirect" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  bucket                  = aws_s3_bucket.frontend_www_redirect.0.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "frontend_www_redirect" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  bucket = aws_s3_bucket.frontend_www_redirect.0.id

  redirect_all_requests_to {
    host_name = "www.${local.site_url}"
    protocol  = "https"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_www_redirect" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  bucket = aws_s3_bucket.frontend_www_redirect.0.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_bucket_frontend_www_redirect.0.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

data "template_file" "frontend_www_redirect_bucket_enforce_tls_statement" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  template = file("${path.module}/policies/s3-bucket-policy-statements/enforce-tls.json.tpl")

  vars = {
    bucket_arn = aws_s3_bucket.frontend_www_redirect.0.arn
  }
}

data "template_file" "frontend_www_redirect_bucket_cloudfront_read" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  template = file("${path.module}/policies/s3-bucket-policy-statements/cloudfront-read.json.tpl")

  vars = {
    bucket_arn             = aws_s3_bucket.frontend_www_redirect.0.arn
    origin_access_identity = aws_cloudfront_origin_access_identity.frontend_www_redirect.0.iam_arn
  }
}

data "template_file" "frontend_www_redirect_bucket_policy" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  template = file("${path.module}/policies/s3-bucket-policy.json.tpl")

  vars = {
    statement = <<EOT
[
${data.template_file.frontend_www_redirect_bucket_enforce_tls_statement.0.rendered},
${data.template_file.frontend_www_redirect_bucket_cloudfront_read.0.rendered}
]
EOT
  }
}

resource "aws_s3_bucket_policy" "frontend_www_redirect" {
  count = local.cloudfront_enable_apex_to_www_redirect ? 1 : 0

  bucket = aws_s3_bucket.frontend_www_redirect.0.id
  policy = data.template_file.frontend_www_redirect_bucket_policy.0.rendered
}
