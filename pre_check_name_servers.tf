data "http" "dns_google_name_servers" {
  url = "https://dns.google/resolve?type=NS&name=${var.bare_domain}"

  request_headers = {
    Accept = "application/dns-json"
  }
}

locals {
  bare_domain = var.bare_domain
  actual_name_servers_response = jsondecode(data.http.dns_google_name_servers.response_body)
  actual_name_servers = sort([
    for answer in lookup(local.actual_name_servers_response, "Answer", []) :trim(answer.data, ".")
  ])
  expected_name_servers = sort(data.aws_route53_zone.zone.name_servers)
}

resource "null_resource" "pre_check_name_servers" {
  lifecycle {
    precondition {
      condition     = local.actual_name_servers == local.expected_name_servers
      error_message = <<-EOT
        The actual name servers retrieved from https://dns.google/resolve?type=NS&name=${var.bare_domain} are:
        [${join(", ", local.actual_name_servers)}]

        They must match the expected name servers set on the hosted zone which are:
        [${join(", ", local.expected_name_servers)}].
      EOT
    }
  }
}
