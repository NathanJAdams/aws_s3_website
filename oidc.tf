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

  url             = local.oidc_bitbucket_url
  client_id_list  = [local.oidc_bitbucket_audience_value]
  thumbprint_list = [var.oidc_bitbucket_thumbprint]
  tags            = var.tags
}

locals {
  oidc_is_bitbucket = (var.oidc_connector == "BitBucket")
  oidc_is_github    = (var.oidc_connector == "GitHub")

  oidc_bitbucket_bare_url          = local.oidc_is_bitbucket ? "api.bitbucket.org/2.0/workspaces/${var.oidc_bitbucket_workspace_name}/pipelines-config/identity/oidc" : null
  oidc_bitbucket_url               = local.oidc_is_bitbucket ? "https://${local.oidc_bitbucket_bare_url}" : null
  oidc_bitbucket_audience_variable = local.oidc_is_bitbucket ? "${local.oidc_bitbucket_bare_url}:aud" : null
  oidc_bitbucket_audience_value    = local.oidc_is_bitbucket ? "ari:cloud:bitbucket::workspace/${trim(var.oidc_bitbucket_workspace_uuid, "{}")}" : null
  oidc_bitbucket_subject_variable  = local.oidc_is_bitbucket ? "${local.oidc_bitbucket_bare_url}:sub" : null
  oidc_bitbucket_subject_value     = local.oidc_is_bitbucket ? "{${trim(var.oidc_bitbucket_repository_uuid, "{}")}}:*" : null

  oidc_github_audience_variable = local.oidc_is_github ? "token.actions.githubusercontent.com:aud" : null
  oidc_github_audience_value    = local.oidc_is_github ? "sts.amazonaws.com" : null
  oidc_github_subject_variable  = local.oidc_is_github ? "token.actions.githubusercontent.com:sub" : null
  oidc_github_subject_value     = local.oidc_is_github ? "repo:${var.oidc_github_account_name}/${var.oidc_github_repository_name}:*" : null

  oidc_provider_arn      = local.oidc_is_bitbucket ? (var.oidc_bitbucket_add_resource ? aws_iam_openid_connect_provider.bitbucket[0].arn : data.aws_iam_openid_connect_provider.bitbucket[0].arn) : (local.oidc_is_github ? data.aws_iam_openid_connect_provider.github[0].arn : "")
  oidc_audience_variable = local.oidc_is_bitbucket ? local.oidc_bitbucket_audience_variable : (local.oidc_is_github ? local.oidc_github_audience_variable : "")
  oidc_audience_value    = local.oidc_is_bitbucket ? local.oidc_bitbucket_audience_value : (local.oidc_is_github ? local.oidc_github_audience_value : "")
  oidc_subject_variable  = local.oidc_is_bitbucket ? local.oidc_bitbucket_subject_variable : (local.oidc_is_github ? local.oidc_github_subject_variable : "")
  oidc_subject_value     = local.oidc_is_bitbucket ? local.oidc_bitbucket_subject_value : (local.oidc_is_github ? local.oidc_github_subject_value : "")
}
