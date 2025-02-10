# Terraform module for a website using S3 and CloudFront

Generates a minimal static website backed by S3, available on your https domain using CloudFront as the CDN, and updatable via an OIDC secured AWS role on BitBucket or GitHub.

## Requirements
A bare domain registered with AWS within a hosted zone.
For details on how to create a hosted zone [see this guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html).
All other necessary resources will be created.

## Usage
The module is hosted on GitHub and can be used by referencing the master branch or tag.
It requires an aws provider in the us-east-1 region named `aws.us_east_1`.
It can be used as follows:

```hcl
provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "example_website" {
  source                      = "github.com/NathanJAdams/aws_s3_website.git?ref=master"
  bare_domain                 = "example.com"
  oidc_role_name              = "UpdateExampleBucket"
  oidc_connector              = "GitHub"
  oidc_github_account_name    = "MyGitHubAccount"
  oidc_github_repository_name = "MyGitHubRepository"
  tags                        = {
    Project     = "Example"
    Environment = "Production"
  }

  providers = {
    aws             = aws
    aws.us_east_1   = aws.us_east_1
  }
}
```

## DNS validation
DNS validation is used to validate the ACM certificate.
Name servers must be consistent for it to take place, otherwise the module is forced to wait until they are.
Therefore it is important to **double-check name servers are consistent** between
- Domain
- Hosted zone
- Publicly accessible name servers, eg. from [https://dns.google/resolve?type=NS&name=example.com](https://dns.google/resolve?type=NS&name=example.com)

This module performs a pre-check between the hosted zone and https://dns.google, but as yet cannot check the domain.
If/when hashicorp provide a domain data source, another pre-check will be included that also checks the domain name servers are consistent.

## Deleting a website
Note that deleting a website will delete the bucket and all objects within it.
If you have any files you want to keep, you should **move them out of the bucket before deleting the website**.

## Variables

| Variables                | Required |    Type     | Default        | Description                                                                                                                                               |
|--------------------------|:--------:|:-----------:|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| bare_domain              |    ✔     |   string    |                | Domain name without a www prefix or leading/trailing dots, eg. `example.com`                                                                              |
| use_bare_domain          |          |   boolean   | false          | Whether www prefixed urls will be redirected to the bare domain. If false, the bare domain will be redirected to the www prefixed domain                  |
| root_file                |          |   string    | index.html     | Bucket key of the root file object                                                                                                                        |
| error_file               |          |   string    | 404.html       | Bucket key of the error file object                                                                                                                       |
| price_class              |          |   string    | PriceClass_100 | CloudFront variable, one of [PriceClass_100, PriceClass_200, PriceClass_All]                                                                              |
| minimum_protocol_version |          |   string    | TLSv1.2_2021   | CloudFront variable, one of [TLSv1.2_2018, TLSv1.2_2019, TLSv1.2_2021]                                                                                    |
| tags                     |          | map(string) | {}             | Map of <key,value> tags to apply to created resources                                                                                                     |
| oidc_role_name           |    ✔     |   string    |                | The name of the role created that will have permissions to update contents of the S3 bucket                                                               |
| oidc_connector           |    ✔     |   string    |                | Which OIDC connector to use, one of [BitBucket, GitHub]                                                                                                   |
| oidc_use_existing_idp    |          |    bool     | true           | Whether to use the existing OIDC identity provider. Set to `false` to create a new one. Only one IDP can be created for GitHub and per BitBucket account. |


## Git provider specific OIDC variables
All the variables in the section associated with `oidc_connector` must be given.

| BitBucket OIDC variables       |  Type  | Description                                          |
|--------------------------------|:------:|------------------------------------------------------|
| oidc_bitbucket_workspace_name  | string | BitBucket specific OIDC connection - Workspace name  |
| oidc_bitbucket_workspace_uuid  | string | BitBucket specific OIDC connection - Workspace UUID  |
| oidc_bitbucket_repository_uuid | string | BitBucket specific OIDC connection - Repository UUID |

| GitHub OIDC variables       |  Type  | Description                                    |
|-----------------------------|:------:|------------------------------------------------|
| oidc_github_account_name    | string | GitHub specific OIDC connection - Account name |
| oidc_github_repository_name | string | GitHub specific OIDC connection - Repository   |

## Outputs

| Outputs                    |  Type  | Description                                                    |
|----------------------------|:------:|----------------------------------------------------------------|
| url                        | string | The website url, eg. https://www.example.com                   |
| bucket                     | string | The bucket where files will be read from, e.g. www.example.com |
| role                       | string | The role with permissions to update the bucket's contents      |
| cloudfront_distribution_id | string | The CloudFront distribution id                                 |

## Deploying your website
Once this module has been used to set up the website, the IAM role it created can be used in the repository to update files on the bucket and invalidate the CloudFront distribution.
If the `oidc_connector` used was `BitBucket` this can be done in the bitbucket-pipelines.yml.
If the `oidc_connector` used was `GitHub` it can be done with a workflow yaml file in the .github/workflows/ folder.

Example BitBucket pipeline:

`

`

Example GitHub workflow:

```yaml
# .github/workflows/deploy-master.yml
name: Deploy

on:
  push:
    branches:
    - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read

    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v3
        with:
          aws-region: ${{ secrets.AWS_REGION }}
          role-to-assume: "arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/${{ secrets.AWS_ROLE }}"
          role-session-name: ${{ env.GITHUB_SHA }}
          retry-max-attempts: 3
          mask-aws-account-id: true

      - name: Checkout
        uses: actions/checkout@v3

      - uses: actions/setup-node@v3
        with:
          node-version: 22

      - name: Install
        run: yarn

      - name: Build
        run: yarn build

      - name: Push to S3
        run: aws s3 sync dist/ s3://${{ secrets.AWS_S3_BUCKET }} --delete

      - name: Invalidate CloudFront
        run: aws cloudfront create-invalidation --distribution-id ${{ secrets.AWS_CLOUDFRONT_DISTRIBUTION_ID }} --paths "/*"
```
