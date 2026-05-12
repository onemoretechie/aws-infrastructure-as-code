# stack: dev

The `dev` stack composes reusable modules into a working development environment.

## What it deploys today

- A VPC across 2 AZs with public, private, and database subnets and a single shared NAT Gateway.

More components (EKS, RDS, etc.) are added in subsequent tutorial episodes.

## Usage

```bash
cd stacks/dev
terraform init
terraform plan
terraform apply
```

> Before running this for the first time, complete the [bootstrap](../../bootstrap/README.md) step and update the `backend "s3"` block in [`versions.tf`](versions.tf) with the bucket name and lock table from its outputs.
