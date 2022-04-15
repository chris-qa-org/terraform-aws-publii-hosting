{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "cloudfront:CreateInvalidation",
      "Effect": "Allow",
      "Resource": "${cloudfront_arn}"
    }
  ]
}
