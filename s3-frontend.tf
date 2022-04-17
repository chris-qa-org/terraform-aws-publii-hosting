resource "aws_s3_bucket" "frontend" {
  bucket        = "frontend-${local.project_name}"
  force_destroy = false
}

resource "aws_iam_user" "publii_s3_frontend" {
  name = "publii-s3-${local.project_name}"
}

data "template_file" "publii_s3_frontend_policy" {
  template = file("${path.module}/policies/s3-rw.json.tpl")

  vars = {
    bucket_arn = aws_s3_bucket.frontend.arn
  }
}

resource "aws_iam_policy" "publii_s3_frontend" {
  name   = "publii-s3-frontend-${local.project_name}"
  policy = data.template_file.publii_s3_frontend_policy.rendered
}

resource "aws_iam_user_policy_attachment" "publii_s3_frontend" {
  user       = aws_iam_user.publii_s3_frontend.name
  policy_arn = aws_iam_policy.publii_s3_frontend.arn
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "frontend" {
  bucket        = aws_s3_bucket.frontend.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3/frontend/"
}

resource "aws_s3_bucket_acl" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.bucket

  index_document {
    suffix = "index.html"
  }
}

# TODO: Use customer key instead
#       This bucket will be used by CloudFront, so a Lambda will need to be created
#       to sign requests
#       https://aws.amazon.com/blogs/networking-and-content-delivery/serving-sse-kms-encrypted-content-from-s3-using-cloudfront/
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "template_file" "frontend_bucket_enforce_tls_statement" {
  template = file("${path.module}/policies/s3-bucket-policy-statements/enforce-tls.json.tpl")

  vars = {
    bucket_arn = aws_s3_bucket.frontend.arn
  }
}

data "template_file" "frontend_bucket_cloudfront_read" {
  template = file("${path.module}/policies/s3-bucket-policy-statements/cloudfront-read.json.tpl")

  vars = {
    bucket_arn             = aws_s3_bucket.frontend.arn
    origin_access_identity = aws_cloudfront_origin_access_identity.frontend.iam_arn
  }
}

data "template_file" "frontend_bucket_policy" {
  template = file("${path.module}/policies/s3-bucket-policy.json.tpl")

  vars = {
    statement = <<EOT
[
${data.template_file.frontend_bucket_enforce_tls_statement.rendered},
${data.template_file.frontend_bucket_cloudfront_read.rendered}
]
EOT
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.template_file.frontend_bucket_policy.rendered
}

resource "aws_s3_bucket_notification" "frontend_cloudfront_invalidation" {
  bucket = aws_s3_bucket.frontend.id

  lambda_function {
    lambda_function_arn = module.lambda_cloudfront_invalidation_frontend.function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "files.publii.json"
  }

  depends_on = [aws_lambda_permission.cloudfront_invalidation_frontend_alllow_s3]
}
