locals {
  certificate_region      = 'us-east-1'
  www_hostname            = "www.${var.bare_domain}"
  main_hostname           = var.use_bare_domain ? var.bare_domain : local.www_hostname
  main_https_hostname     = "https://${local.main_hostname}"
  main_s3_hostname        = "S3-${local.main_hostname}"
  redirect_hostname       = var.use_bare_domain ? local.www_hostname : var.bare_domain
  redirect_https_hostname = "https://${local.redirect_hostname}"
  redirect_s3_hostname    = "S3-${local.redirect_hostname}"
  hostnames               = toset([local.main_hostname, local.redirect_hostname])
}
