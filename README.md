# Terraform module for a website using S3 and CloudFront

Generates an empty website backed by S3, available on a https url using CloudFront as the CDN.

## Requirements
It requires a bare domain registered with AWS within a hosted zone.
For details on how to create a hosted zone, see [this guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html).
The module will create all other necessary resources.

## Usage

The module is hosted on GitHub and can be used by referencing the master branch.
It requires a aws provider in the us-east-1 region named `aws.us_east_1`.
It can be used as follows:

```hcl
provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "website" {
  source      = "github.com/NathanJAdams/aws_s3_website.git?ref=master"
  bare_domain = "example.com"

  providers = {
    aws             = aws
    aws.us_east_1   = aws.us_east_1
  }
}
```

## Deleting a website
Note that deleting a website will delete the bucket and all objects within it.
If you have any files you want to keep, you should move them out of the bucket before deleting the website.

## Variables

| Variables                | Required |  Type   | Default        | Description                                                                                                                 |
|--------------------------|:--------:|:-------:|----------------|-----------------------------------------------------------------------------------------------------------------------------|
| bare_domain              |    ✔     | string  |                | Domain name without a www prefix or leading/trailing dots, eg. `example.com`                                                |
| use_bare_domain          |          | boolean | false          | Whether urls will be redirected to the bare domain. If false, the bare domain will be redirected to the www prefixed domain |
| root_file                |          | string  | index.html     | Bucket key of the root file object                                                                                          |
| error_file               |          | string  | 404.html       | Bucket key of the error file object                                                                                         |
| price_class              |          | string  | PriceClass_100 | CloudFront variable, one of [PriceClass_100, PriceClass_200, PriceClass_All]                                                |
| minimum_protocol_version |          | string  | TLSv1.2_2021   | CloudFront variable, one of [TLSv1.2_2018, TLSv1.2_2019, TLSv1.2_2021]                                                      |

| Outputs |  Type  | Description                                                    |
|---------|:------:|----------------------------------------------------------------|
| url     | string | The website url, eg. https://www.example.com                   |
| bucket  | string | The bucket where files will be read from, e.g. www.example.com |
