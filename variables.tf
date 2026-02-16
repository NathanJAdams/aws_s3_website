variable "bare_domain" {
  type        = string
  description = "Domain name without a www prefix or leading/trailing dots, eg. example.com"
}

variable "use_bare_domain" {
  default     = false
  type        = bool
  description = "Whether urls will redirect to the bare domain. If false, the bare domain will be redirected to the www prefixed domain"
}

variable "root_file" {
  default     = "index.html"
  type        = string
  description = "The root file object, eg. index.html"
}

variable "error_file" {
  default     = "404.html"
  type        = string
  nullable    = true
  description = "The error file object to be shown for 403 and 404 responses from AWS S3, eg. 404.html. Set this to null to use root_file instead"
}

variable "price_class" {
  default     = "PriceClass_100"
  type        = string
  description = "CloudFront variable, one of [PriceClass_100, PriceClass_200, PriceClass_All]"
  validation {
    condition = anytrue([
      var.price_class == "PriceClass_100",
      var.price_class == "PriceClass_200",
      var.price_class == "PriceClass_All"
    ])
    error_message = "price_class must be one of [PriceClass_100, PriceClass_200, PriceClass_All]"
  }
}

variable "minimum_protocol_version" {
  default     = "TLSv1.2_2021"
  type        = string
  description = "CloudFront variable, one of [TLSv1.2_2018, TLSv1.2_2019, TLSv1.2_2021]"
  validation {
    condition = anytrue([
      var.minimum_protocol_version == "TLSv1.2_2018",
      var.minimum_protocol_version == "TLSv1.2_2019",
      var.minimum_protocol_version == "TLSv1.2_2021"
    ])
    error_message = "minimum_protocol_version must be one of [TLSv1.2_2018, TLSv1.2_2019, TLSv1.2_2021]"
  }
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Map of key->value tags to apply to created resources"
}

variable "oidc_role_name" {
  type        = string
  description = "The role name created that will be able to update contents on the S3 bucket"
}

variable "oidc_connector" {
  type        = string
  description = "Which OIDC connector to use, one of [BitBucket, GitHub]"
  validation {
    condition = anytrue([
      var.oidc_connector == "BitBucket",
      var.oidc_connector == "GitHub"
    ])
    error_message = "oidc_connector must be one of [BitBucket, GitHub]"
  }
}

variable "oidc_use_existing_idp" {
  type        = bool
  default     = true
  description = "Whether to use the existing OIDC identity provider. Set to `false` to create a new one. Only one IDP is needed per git provider (BitBucket or GitHub)"
}

variable "oidc_bitbucket_workspace_name" {
  default     = null
  type        = string
  description = "BitBucket specific OIDC connection | Workspace name"
}

variable "oidc_bitbucket_workspace_uuid" {
  default     = null
  type        = string
  description = "BitBucket specific OIDC connection | Workspace UUID"
}

variable "oidc_bitbucket_repository_uuid" {
  default     = null
  type        = string
  description = "BitBucket specific OIDC connection | Repository UUID"
}

variable "oidc_github_account_name" {
  default     = null
  type        = string
  description = "GitHub specific OIDC connection | Account name"
}

variable "oidc_github_repository_name" {
  default     = null
  type        = string
  description = "GitHub specific OIDC connection | Repository name"
}
