{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:List*",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning"
      ],
      "Effect": "Allow",
      "Resource": [
        "${bucket_arn}",
        "${bucket_arn}/*"
      ]
    },
    {
      "Action": [
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": [
        "${kms_key_arn}"
      ]
    }
  ]
}
