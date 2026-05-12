# module: vpc

A production-ready VPC with public, private, and database subnets across multiple AZs.

## Features

- Configurable CIDR block, AZ count, and subnet sizing.
- Public subnets with an Internet Gateway and per-AZ default route.
- Private subnets with optional NAT Gateways (one-per-AZ or single shared) for cost control.
- Database subnets that are isolated by default (no egress to the internet).
- VPC Flow Logs to CloudWatch Logs (optional).

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name               = "dev"
  cidr_block         = "10.20.0.0/16"
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  nat_gateway_mode   = "single"   # "single" | "per_az" | "none"

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

See [`variables.tf`](variables.tf) for the full list with descriptions and defaults.

## Outputs

See [`outputs.tf`](outputs.tf). The most useful outputs are `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, and `database_subnet_ids`.
