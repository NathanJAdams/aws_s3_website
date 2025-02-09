output "url" {
  value = local.main_https_hostname
}

output "bucket" {
  value = aws_s3_bucket.main.id
}

output "role" {
  value = aws_iam_role.role.name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.main.id
}
