# AWS S3 Public Web Module

Creates an S3 public bucket configured for web access with cloudfront. 

This module will create:

* 1x S3 Bucket.
* 1x Cloudfront CDN distribution.
* 1x Route53 needed entries.
* 1x SSL Certificate for the CDN.
* 1x IAM user with access to upload to the S3 bucket and reset the CDN's cache.

## Input Variables

* `name` **string** REQUIRED A unique slug which will be used as the S3 bucket name, 
    tagging and wherever else a unique identifier is needed.
* `taget_hostname` **string** REQUIRED The desired hostname the public S3 
    web bucket will be available at.
* `region` **string** The desired region to create the bucket on (default EU West `eu-west-1`).
* `zone_id` **string** The Route53 id to attach the rules on 
    (i.e. `aws_route53_zone.srop.zone_id`).
* `authentication` **Map** A single key/value pair to activate HTTP Basic 
    Authentication.

## Requires Explicit Providers

Because cloudfront SSL certificates can only be issued from the Virginia data
center, this module requires explicit providers be available.

If your root configuration has the following providers:

```terraform
provider "aws" {
  version = "~> 2.26.0"
  region  = "eu-west-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
```

You should have the following configuration for the module:

```terraform
  providers = {
    aws.main     = aws
    aws.virginia = aws.virginia
  }
```

## Full Example

How to use the S3 Web Module in full:

```terraform
module "s3web" {
  source = "../modules/aws-s3-public-web"

  name            = "srop-demo-frontend"
  target_hostname = "demo.srop.co"
  zone_id         = aws_route53_zone.srop.zone_id
  
  authentication  = [
    "username:password",
  ]

  providers = {
    aws.main     = aws
    aws.virginia = aws.virginia
  }
}
```

[Read more about passing providers to modules](https://www.terraform.io/docs/configuration/modules.html#passing-providers-explicitly).
