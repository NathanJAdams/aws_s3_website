resource "aws_s3_bucket" "redirect" {
  provider      = aws.website

  bucket = local.redirect_hostname
}

resource "aws_s3_bucket_public_access_block" "redirect" {
  provider      = aws.website

  bucket                  = aws_s3_bucket.redirect.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "redirect" {
  provider      = aws.website

  bucket = aws_s3_bucket.redirect.bucket
  redirect_all_requests_to {
    protocol  = "http"
    host_name = local.main_hostname
  }
}
