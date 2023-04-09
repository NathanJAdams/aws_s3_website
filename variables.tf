variable "bare_domain" {
  type        = string
  description = "Domain name without a www prefix or leading/trailing dots, eg. example.com"
}

variable "use_bare_domain" {
  type        = bool
  default     = false
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
  description = "The error file object, eg. 404.html"
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
