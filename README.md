# CloudFront S3 Website terraform module

Generates an empty website backed by S3, available on a https url using CloudFront as the CDN.
This requires a registered bare domain within a hosted zone.
The `add_initial_files` flag will determine what will be shown once the website is deployed.

 - If true, an initial home page provided by the module
 - If false, a KeyNotFound error

This means the website structure has been successfully deployed and is ready for your files to be added to the bucket.

## Usage

This module requires 2 aws providers

 - `aws`: a provider for the region to deploy into
 - `aws.us_east_1`: a provider that must use the us-east-1 region - CloudFront requires certificates to be in this region

It can be created with the code:

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.28.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "s3website" {
  source  = "github.com/NathanJAdams/aws_s3_website.git?ref=master"
  bare_domain = "example.com"
  providers   = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}

```

## Variables

| Variables                | Required |  Type   | Default        | Description                                                                                                                 |
|--------------------------|:--------:|:-------:|----------------|-----------------------------------------------------------------------------------------------------------------------------|
| bare_domain              |    ✔     | string  |                | Domain name without a www prefix or leading/trailing dots, eg. example.com                                                  |
| use_bare_domain          |          | boolean | false          | Whether urls will be redirected to the bare domain. If false, the bare domain will be redirected to the www prefixed domain |
| add_initial_files        |          | boolean | true           | Whether to add initial root and error files                                                                                 |
| root_file                |          | string  | index.html     | Path to the root file object                                                                                                |
| error_file               |          | string  | 404.html       | Path to the error file object                                                                                               |
| price_class              |          | string  | PriceClass_100 | CloudFront variable, one of [PriceClass_100, PriceClass_200, PriceClass_All]                                                |
| minimum_protocol_version |          | string  | TLSv1.2_2021   | CloudFront variable, one of [TLSv1.2_2018, TLSv1.2_2019, TLSv1.2_2021]                                                      |

| Outputs |  Type  | Description                                                    |
|---------|:------:|----------------------------------------------------------------|
| url     | string | The website url, eg. https://www.example.com                   |
| bucket  | string | The bucket where files will be read from, e.g. www.example.com |
