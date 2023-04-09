resource "aws_cloudfront_origin_access_identity" "oai" {
  provider      = aws.website
}
