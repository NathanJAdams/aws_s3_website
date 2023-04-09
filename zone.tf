data "aws_route53_zone" "zone" {
  name = var.bare_domain
}
