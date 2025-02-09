resource "aws_s3_bucket" "main" {
  bucket        = local.main_hostname
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_object" "main_initial_root_file" {
  bucket       = aws_s3_bucket.main.id
  key          = var.root_file
  content_type = "text/html"
  content      = templatefile("${path.module}/initial_files/index.html", {
    BUCKET = local.main_hostname
  })

  lifecycle {
    ignore_changes = [source]
  }
}

resource "aws_s3_object" "main_initial_error_file" {
  bucket       = aws_s3_bucket.main.id
  key          = var.error_file
  content_type = "text/html"
  content      = templatefile("${path.module}/initial_files/404.html", {
    HOME = var.bare_domain
  })

  lifecycle {
    ignore_changes = [source]
  }
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

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.main.json
}
