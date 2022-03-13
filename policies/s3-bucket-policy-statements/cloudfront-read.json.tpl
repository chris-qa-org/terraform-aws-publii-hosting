{
  "Principal": {
    "AWS": "${origin_access_identity}"
  },
  "Action": "s3:GetObject",
  "Effect": "Allow",
  "Resource": [
    "${bucket_arn}",
    "${bucket_arn}/*"
  ]
}
