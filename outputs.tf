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
