resource "null_resource" "pre_check_oidc_providers" {
  lifecycle {
    precondition {
      condition = anytrue([
        alltrue([
          try(data.aws_iam_openid_connect_provider.existing_oidc_provider.arn, null) == null,
          !var.oidc_use_existing_idp
        ]),
        alltrue([
          try(data.aws_iam_openid_connect_provider.existing_oidc_provider.arn, null) != null,
          var.oidc_use_existing_idp
        ])
      ])
      error_message = "If oidc_use_existing_idp is true or left as the default value (true), then there must be an existing OIDC identity provider. If false, there must `not` be an existing OIDC identity provider."
    }
  }
}
