# module: ecr

Single ECR repository with immutable tags, scan-on-push, lifecycle expiry, and an optional cross-account pull policy.

## Features

- Immutable tags by default — pushing the same tag twice is an error.
- Scan-on-push (basic image scanning) enabled.
- Encryption via AES256, or KMS when `kms_key_arn` is set.
- Lifecycle policy generated from inputs: keep last N images per tag prefix, expire untagged images after N days.
- Optional repository policy granting pull-only access to a list of principal ARNs.

## Usage

```hcl
module "ecr_app" {
  source = "../../modules/ecr"

  name                         = "sample-web-app"
  lifecycle_keep_last_n_tagged = 30
  lifecycle_tag_prefixes       = ["v", "release-"]
  lifecycle_untagged_expire_days = 7

  allowed_pull_principal_arns = [module.eks_node_role.role_arn]

  tags = { Environment = "dev" }
}
```

## Inputs

See [`variables.tf`](variables.tf).

## Outputs

`repository_name`, `repository_arn`, `repository_url`, `registry_id`.
