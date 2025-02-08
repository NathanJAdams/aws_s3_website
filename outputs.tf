output "url" {
  value = local.main_https_hostname
}

output "bucket" {
  value = aws_s3_bucket.main.id
}

output "role" {
  value = aws_iam_role.role.name
}
