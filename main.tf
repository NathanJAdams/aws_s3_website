terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~>4.28.0"
      configuration_aliases = ["us-east-1"]
    }
  }
}
