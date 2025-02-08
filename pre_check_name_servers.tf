data "http" "dns_google_name_servers" {
  url = "https://dns.google/resolve?name=${var.bare_domain}&type=NS"

  request_headers = {
    Accept = "application/dns-json"
  }
}

locals {
  actual_name_servers_response = jsondecode(data.http.dns_google_name_servers.response_body)
  actual_name_servers = reverse(sort([for answer in lookup(local.actual_name_servers_response, "Answer", []) : answer.data]))
  expected_name_servers = sort(data.aws_route53_zone.zone.name_servers)
  zone_name = data.aws_route53_zone.zone.name
}

resource "null_resource" "pre_check_name_servers" {
  count = 0

  lifecycle {
    precondition {
      condition     = local.actual_name_servers == local.expected_name_servers
      error_message = "The name servers for ${var.bare_domain}: ${local.actual_name_servers} must match those from it's hosted zone ${local.zone_name}: ${local.expected_name_servers}."
    }
  }
}
