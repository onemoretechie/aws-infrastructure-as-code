# module: s3

Opinionated S3 bucket primitive: encrypted, versioned, public access blocked, ACLs disabled.

## Features

- Server-side encryption (SSE-S3 by default, SSE-KMS when `kms_key_arn` is set, with bucket key on).
- Versioning enabled by default.
- Public access fully blocked by default; opt out only when serving a public website directly.
- `BucketOwnerEnforced` ownership — ACLs disabled, IAM is the only auth model.
- Optional lifecycle rules (transitions, expirations, abort multipart uploads).
- Optional CORS configuration and server access logging.

## Usage

```hcl
module "uploads" {
  source = "../../modules/s3"

  name        = "myco-dev-uploads"
  kms_key_arn = module.kms_s3.key_arn

  lifecycle_rules = [{
    id = "expire-old-versions"
    transitions = [
      { days = 30, storage_class = "STANDARD_IA" },
      { days = 90, storage_class = "GLACIER" },
    ]
    noncurrent_version_expiration_days     = 180
    abort_incomplete_multipart_upload_days = 7
  }]

  tags = { Environment = "dev" }
}
```

## Inputs

See [`variables.tf`](variables.tf).

## Outputs

`bucket_id`, `bucket_arn`, `bucket_domain_name`, `bucket_hosted_zone_id`.
