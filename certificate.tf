resource "aws_acm_certificate" "certificate" {
  provider          = aws.us_east_1
  domain_name       = var.bare_domain
  validation_method = "DNS"
  tags              = var.tags
  subject_alternative_names = [
    "*.${var.bare_domain}"
  ]
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
  type            = each.value.resource_record_type
  zone_id         = data.aws_route53_zone.zone.zone_id
  ttl             = 60
  records = [each.value.resource_record_value]
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_record : record.fqdn]
}
