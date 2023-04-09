resource "aws_acm_certificate" "certificate" {
  provider                  = local.certificate_region
  domain_name               = var.bare_domain
  subject_alternative_names = [
    "*.${var.bare_domain}"
  ]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "certificate_record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options :
    dvo.domain_name => dvo
    if dvo.domain_name == var.bare_domain
  }

  allow_overwrite = true
  name            = each.value.resource_record_name
  records         = [each.value.resource_record_value]
  type            = each.value.resource_record_type
  zone_id         = data.aws_route53_zone.zone.zone_id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  provider                = local.certificate_region
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_record : record.fqdn]
}
