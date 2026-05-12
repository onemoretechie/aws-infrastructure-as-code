# module: cloudfront

CloudFront distribution in front of either an S3 origin (static sites/SPAs) or a custom HTTP origin (ALB, API Gateway, etc.).

## Origin selection

Exactly one of `s3_origin` or `custom_origin` must be set:

- **S3 origin** — the module creates an Origin Access Control (OAC) and writes a bucket policy granting CloudFront `s3:GetObject` on the bucket. The bucket should keep all public access blocked.
- **Custom origin** — pass the ALB DNS name (or any HTTPS endpoint). Optional `custom_headers` are sent on every origin request (useful for shared-secret auth between CloudFront and the origin).

## TLS + aliases

Set `aliases` to your domain names and `certificate_arn` to an ACM certificate **in us-east-1** covering them. Wire DNS via the `route53` module with an alias record pointing to `domain_name` / `hosted_zone_id`.

## Usage — static site from S3

```hcl
module "cdn" {
  source = "../../modules/cloudfront"

  name                = "dev-site"
  aliases             = ["cdn.example.com"]
  certificate_arn     = module.acm_cf.certificate_arn
  default_root_object = "index.html"

  s3_origin = {
    bucket_regional_domain_name = module.site_bucket.bucket_domain_name
    bucket_arn                  = module.site_bucket.bucket_arn
  }

  tags = { Environment = "dev" }
}
```

## Usage — in front of an ALB

```hcl
module "cdn" {
  source = "../../modules/cloudfront"

  name            = "prod-edge"
  aliases         = ["www.example.com"]
  certificate_arn = module.acm_cf.certificate_arn

  custom_origin = {
    domain_name = module.alb.alb_dns_name
    custom_headers = {
      "X-Origin-Verify" = var.origin_verify_secret
    }
  }

  default_cache_behavior = {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
  }

  tags = { Environment = "prod" }
}
```

## Inputs

See [`variables.tf`](variables.tf).

## Outputs

`distribution_id`, `distribution_arn`, `domain_name`, `hosted_zone_id`, `origin_access_control_id`.
