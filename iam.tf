data "aws_iam_policy_document" "s3_readwrite" {
    statement {
        actions = [
            "s3:*Object",
            "s3:ListBucket",
        ]

        resources = [
            aws_s3_bucket.s3.arn,
            "${aws_s3_bucket.s3.arn}/*",
        ]
    }
}