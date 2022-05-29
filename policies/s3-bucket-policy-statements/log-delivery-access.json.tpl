{
  "Principal": {
    "Service": "logging.s3.amazonaws.com"
  },
  "Action": [
    "s3:PutObject"
  ],
  "Effect": "Allow",
  "Resource": "${log_bucket_arn}/*",
  "Condition": {
    "ArnLike": {
      "aws:SourceArn": ${source_bucket_arns}
    },
    "StringEquals": {
      "aws:SourceAccount": "${account_id}"
    }
  }
}
