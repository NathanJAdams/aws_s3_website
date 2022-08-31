resource "aws_s3_bucket" "main" {
  bucket        = local.main_hostname
  force_destroy = var.delete_all_files_on_destroy
}

resource "aws_s3_object" "main_initial_root_file" {
  count = var.add_initial_files ? 1 : 0

  bucket = aws_s3_bucket.main.id
  key    = var.root_file
  source = templatefile("initial_files/index.html", {
    BUCKET = local.main_hostname
  })
}

resource "aws_s3_object" "main_initial_error_file" {
  count = var.add_initial_files ? 1 : 0

  bucket = aws_s3_bucket.main.id
  key    = var.error_file
  source = templatefile("initial_files/404.html", {
    HOME = var.bare_domain
  })
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket
  index_document {
    suffix = var.root_file
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = [local.main_https_hostname]
    max_age_seconds = 3600
  }
}

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

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.main.json
}
