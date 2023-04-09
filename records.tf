resource "aws_route53_record" "records" {
  provider      = aws.website

  for_each = tomap({
    (local.main_hostname) = {
      zone_id = aws_cloudfront_distribution.main.hosted_zone_id
      name    = aws_cloudfront_distribution.main.domain_name
    }
    (local.redirect_hostname) = {
      zone_id = aws_cloudfront_distribution.redirect.hosted_zone_id
      name    = aws_cloudfront_distribution.redirect.domain_name
    }
  })

  zone_id = data.aws_route53_zone.zone.zone_id
  name    = each.key
  type    = "A"
  alias {
    zone_id                = each.value.zone_id
    name                   = each.value.name
    evaluate_target_health = false
  }
}
