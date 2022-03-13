locals {
  site_url          = var.site_url
  project_random_id = random_id.project.dec
  project_name      = "${replace(local.site_url, ".", "-")}-${local.project_random_id}"
  s3_bucket_acl     = var.s3_bucket_acl
}
