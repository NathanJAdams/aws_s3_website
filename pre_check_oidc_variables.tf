resource "null_resource" "pre_check_oidc_variables" {
  lifecycle {
    precondition {
      condition = anytrue([
        alltrue([
          (var.oidc_connector == "BitBucket"),
          (var.oidc_bitbucket_repository_uuid != null),
          (var.oidc_bitbucket_thumbprint != null),
          (var.oidc_bitbucket_workspace_name != null),
          (var.oidc_bitbucket_workspace_uuid != null),
          (var.oidc_github_account_name == null),
          (var.oidc_github_repository_name == null),
        ]),
        alltrue([
          (var.oidc_connector == "GitHub"),
          (var.oidc_bitbucket_repository_uuid == null),
          (var.oidc_bitbucket_thumbprint == null),
          (var.oidc_bitbucket_workspace_name == null),
          (var.oidc_bitbucket_workspace_uuid == null),
          (var.oidc_github_account_name != null),
          (var.oidc_github_repository_name != null),
        ]),
      ])
      error_message = "oidc_connector must be one of [BitBucket, GitHub]. All it's associated oidc_... variables must not be null. All other unused oidc_... variables must be null."
    }
  }
}
