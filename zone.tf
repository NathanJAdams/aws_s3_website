data "aws_route53_zone" "zone" {
  provider      = aws.website

  name = var.bare_domain
}
