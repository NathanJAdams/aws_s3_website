# Terraform module for a website using S3 and CloudFront

Generates an empty website backed by S3, available on a https url using CloudFront as the CDN.

It requires a bare domain registered with AWS within a hosted zone.

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
