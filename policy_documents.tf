data "aws_iam_policy_document" "main" {
  statement {
    sid = "ReadFiles"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.main.arn}/*",
    ]
  }
  statement {
    sid = "ReadFolders"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.main.arn
    ]
  }
}
