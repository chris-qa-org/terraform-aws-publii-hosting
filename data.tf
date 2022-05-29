data "aws_route53_zone" "default" {
  count = local.route53_hosted_zone_options.id != "" ? 1 : 0

  zone_id = local.route53_hosted_zone_options.id
}

data "aws_caller_identity" "current" {}
