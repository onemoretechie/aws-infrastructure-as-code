# module: acm

ACM public certificate issued via DNS-01 validation against a Route53 hosted zone you already own.

## How it works

1. The certificate request is created with `validation_method = "DNS"`.
2. For each domain on the cert, a CNAME validation record is written into `hosted_zone_id`.
3. If `wait_for_validation` is true (default), the apply blocks until ACM marks the cert `ISSUED`.

All domains on the cert must live in the same hosted zone.

## Note on CloudFront

CloudFront requires certificates from **us-east-1**. When you wire this module into a CloudFront distribution, instantiate it under a provider alias pinned to `us-east-1`:

```hcl
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "acm_cf" {
  source = "../../modules/acm"
  providers = {
    aws = aws.us_east_1
  }

  domain_name    = "cdn.example.com"
  hosted_zone_id = module.dns.zone_id
}
```

## Usage — ALB cert (regional)

```hcl
module "acm_edge" {
  source = "../../modules/acm"

  domain_name               = "example.com"
  subject_alternative_names = ["www.example.com"]
  hosted_zone_id            = module.dns.zone_id

  tags = { Environment = "prod" }
}
```

## Inputs

See [`variables.tf`](variables.tf).

## Outputs

`certificate_arn`, `certificate_domain_name`, `certificate_status`.
