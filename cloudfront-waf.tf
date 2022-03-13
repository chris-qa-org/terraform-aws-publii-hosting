resource "aws_wafv2_web_acl" "cloudfront_waf" {
  provider = aws.useast1

  name        = "${local.project_name}-acl"
  description = "${local.project_name} ACL"
  scope       = "CLOUDFRONT"

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = local.project_name
    sampled_requests_enabled   = true
  }

  default_action {
    allow {}
  }
}
