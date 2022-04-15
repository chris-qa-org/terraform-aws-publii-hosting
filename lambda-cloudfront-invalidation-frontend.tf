data "template_file" "lambda_cloudfront_invalidation_frontend_policy" {
  template = file("${path.module}/policies/cloudfront-invalidation.json.tpl")

  vars = {
    cloudfront_arn = aws_cloudfront_distribution.frontend.arn
  }
}

module "lambda_cloudfront_invalidation_frontend" {
  source = "github.com/claranet/terraform-aws-lambda?ref=v1.4.0"

  function_name = "${local.project_name}-cloudfront-invalidation-frontend"
  description   = "${local.project_name} CloudFront invalidation frontend"
  handler       = "function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 900
  memory_size   = 128

  source_path = "${path.module}/lambdas/cloudfront-invalidation/function.py"

  policy = {
    json = data.template_file.lambda_cloudfront_invalidation_frontend_policy.rendered
  }

  tracing_config = {
    mode = "Active"
  }

  environment = {
    variables = {
      cloudFrontDistributionId = aws_cloudfront_distribution.frontend.id
    }
  }
}

resource "aws_lambda_permission" "cloudfront_invalidation_frontend_alllow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_cloudfront_invalidation_frontend.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.frontend.arn
}
