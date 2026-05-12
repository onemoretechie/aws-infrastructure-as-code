# stack: dev

The `dev` stack composes the reusable modules into a cheap, single-AZ-NAT working environment. It deliberately leaves expensive components (EKS, ALB, CloudFront) out — see [`stacks/prod`](../prod) for the HA composition.

## What it deploys

| Component | Module | Notes |
| --- | --- | --- |
| VPC across 2 AZs with public / private / database subnets | [`modules/vpc`](../../modules/vpc) | Single shared NAT Gateway to keep cost low. |
| KMS key for S3 | [`modules/kms`](../../modules/kms) | Used by the uploads bucket. |
| Uploads S3 bucket | [`modules/s3`](../../modules/s3) | Versioned, SSE-KMS, public access blocked. |
| ECR repo for `sample-web-app` | [`modules/ecr`](../../modules/ecr) | Immutable tags, scan-on-push, lifecycle expiry. |
| SSM-managed EC2 IAM role + instance profile | [`modules/iam`](../../modules/iam) | Attach to any dev EC2 box for Session Manager. |
| RDS Postgres (optional) | [`modules/rds`](../../modules/rds) | Off by default. Set `enable_rds = true`. |

## Required input

`bucket_name_prefix` has no default — buckets are globally unique. Pick a 3-10 character prefix (your company / personal handle).

## Usage

```bash
cd stacks/dev
terraform init
terraform plan  -var bucket_name_prefix=omt
terraform apply -var bucket_name_prefix=omt
```

Or pass via a `.tfvars` file:

```hcl
# stacks/dev/terraform.tfvars (don't commit)
bucket_name_prefix = "omt"
enable_rds         = false
```

> Before running this for the first time, complete the [bootstrap](../../bootstrap/README.md) step and update the `backend "s3"` block in [`versions.tf`](versions.tf) with the bucket name and lock table from its outputs.
