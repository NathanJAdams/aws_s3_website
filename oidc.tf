data "aws_iam_openid_connect_provider" "bitbucket" {
  count = (local.oidc_is_bitbucket && !var.oidc_bitbucket_add_resource) ? 1 : 0

  url = local.oidc_bitbucket_url
}

data "aws_iam_openid_connect_provider" "github" {
  count = local.oidc_is_github ? 1 : 0

  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "bitbucket" {
  count = (local.oidc_is_bitbucket && var.oidc_bitbucket_add_resource) ? 1 : 0

  url = local.oidc_bitbucket_url
  client_id_list = [local.oidc_bitbucket_audience_value]
  thumbprint_list = [var.oidc_bitbucket_thumbprint]
}

locals {
  oidc_is_bitbucket = (var.oidc_connector == "BitBucket")
  oidc_is_github    = (var.oidc_connector == "GitHub")

  oidc_bitbucket_bare_url          = "api.bitbucket.org/2.0/workspaces/${var.oidc_bitbucket_workspace_name}/pipelines-config/identity/oidc"
  oidc_bitbucket_url               = "https://${local.oidc_bitbucket_bare_url}"
  oidc_bitbucket_audience_variable = "${local.oidc_bitbucket_bare_url}:aud"
  oidc_bitbucket_audience_value    = "ari:cloud:bitbucket::workspace/${trim(var.oidc_bitbucket_workspace_uuid, "{}")}"
  oidc_bitbucket_subject_variable  = "${local.oidc_bitbucket_bare_url}:sub"
  oidc_bitbucket_subject_value     = "{${trim(var.oidc_bitbucket_repository_uuid, "{}")}}:*"

  oidc_github_audience_variable = "token.actions.githubusercontent.com:aud"
  oidc_github_audience_value    = "sts.amazonaws.com"
  oidc_github_subject_variable  = "token.actions.githubusercontent.com:sub"
  oidc_github_subject_value     = "repo:${var.oidc_github_account_name}/${var.oidc_github_repository_name}:*"

  oidc_provider_arn = local.oidc_is_bitbucket
    ? var.oidc_bitbucket_add_resource
      ? aws_iam_openid_connect_provider.bitbucket[0].arn
      : data.aws_iam_openid_connect_provider.bitbucket[0].arn
    : local.oidc_is_github
      ? data.aws_iam_openid_connect_provider.github[0].arn
      : ""
  oidc_audience_variable = local.oidc_is_bitbucket
    ? local.oidc_bitbucket_audience_variable
    : local.oidc_is_github
      ? local.oidc_github_audience_variable
      : ""
  oidc_audience_value = local.oidc_is_bitbucket
    ? local.oidc_bitbucket_audience_value
    : local.oidc_is_github
      ? local.oidc_github_audience_value
      : ""
  oidc_subject_variable = local.oidc_is_bitbucket
    ? local.oidc_bitbucket_subject_variable
    : local.oidc_is_github
      ? local.oidc_github_subject_variable
      : ""
  oidc_subject_value = local.oidc_is_bitbucket
    ? local.oidc_bitbucket_subject_value
    : local.oidc_is_github
      ? local.oidc_github_subject_value
      : ""
}
