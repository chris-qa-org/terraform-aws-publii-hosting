output "project_random_id" {
  description = "The random ID generated to ensure unique resource names"
  value       = local.project_random_id
}

output "project_name" {
  description = "Project name. Generated from the site_url and project_random_id"
  value       = local.project_name
}

output "s3_bucket_frontend" {
  description = "S3 bucket frontend attributes"
  value       = aws_s3_bucket.frontend
}

output "iam_user_publii_s3_frontend" {
  description = "IAM User attributes for Publii S3 bucket"
  value       = aws_iam_user.publii_s3_frontend
}
