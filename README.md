# aws-infrastructure-as-code

A modular, production-grade reference architecture for building AWS infrastructure with Terraform.

This repository is the companion codebase for the **OneMoreTechie** tutorial series on AWS infrastructure-as-code. It is designed to be:

- **Reusable** — small, composable modules you can lift into your own projects.
- **Opinionated** — sensible defaults that reflect what real production environments look like.
- **Teachable** — each module and stack is structured to map cleanly to a tutorial episode.

## What's inside

| Path | Purpose |
| --- | --- |
| [`bootstrap/`](bootstrap/) | One-time setup: remote state S3 bucket + DynamoDB lock table. Run this first. |
| [`modules/`](modules/) | Reusable building blocks. See the table below. |
| [`stacks/`](stacks/) | Environment-scoped compositions (`dev`, `prod`) that wire modules together. |
| [`docs/`](docs/) | Architecture diagrams and tutorial companion notes. |

## Modules

| Module | What it builds |
| --- | --- |
| [`modules/vpc`](modules/vpc/) | Multi-AZ VPC with public, private, and database subnets; optional flow logs. |
| [`modules/kms`](modules/kms/) | Customer-managed KMS key with annual rotation, alias, and a generated key policy. |
| [`modules/s3`](modules/s3/) | Hardened S3 bucket — SSE-KMS, versioning, public access blocked, lifecycle rules. |
| [`modules/iam`](modules/iam/) | Reusable IAM role factory with service / aws / OIDC / custom trust types. |
| [`modules/ecr`](modules/ecr/) | ECR repo with immutable tags, scan-on-push, and lifecycle expiry. |
| [`modules/rds`](modules/rds/) | Encrypted RDS (Postgres or MySQL) in isolated subnets with Secrets-Manager-managed master credentials. |
| [`modules/route53`](modules/route53/) | Hosted zone (public or private) plus a map-driven record set. |
| [`modules/acm`](modules/acm/) | ACM certificate issued via DNS-01 validation. |
| [`modules/alb`](modules/alb/) | Application Load Balancer with default target group and HTTP→HTTPS redirect listener. |
| [`modules/eks`](modules/eks/) | EKS cluster + managed node group + OIDC provider for IRSA. |
| [`modules/cloudfront`](modules/cloudfront/) | CloudFront distribution in front of either an S3 origin (OAC) or an ALB. |

## Requirements

- **Terraform** `>= 1.9.0`
- **AWS provider** `~> 5.0`
- AWS account with credentials configured (env vars, profile, or SSO)

A [`.terraform-version`](.terraform-version) file is included for [`tfenv`](https://github.com/tfutils/tfenv) users.

## Getting started

```bash
# 1. Bootstrap the remote state backend (run once per AWS account)
cd bootstrap
terraform init
terraform apply

# 2. Initialise and apply a stack
cd ../stacks/dev
terraform init
terraform plan
terraform apply
```

After the bootstrap completes, every other stack stores its state in S3 with DynamoDB-based locking.

## Repository conventions

- **Terraform formatting** — `terraform fmt -recursive` before every commit.
- **Module interfaces** — each module declares `variables.tf`, `outputs.tf`, `versions.tf`, and one or more resource files.
- **No secrets in code** — secrets live in AWS Secrets Manager or SSM Parameter Store; module inputs reference ARNs, not values.
- **Tags** — every resource carries `Project`, `Environment`, `ManagedBy = "terraform"`, and `Owner` tags via a shared `default_tags` block.

## Tutorial roadmap

Each tutorial episode maps to a specific module or stack. See [`docs/tutorials/`](docs/tutorials/) for the running index as episodes are published.

## License

[MIT](LICENSE) — use, fork, and adapt freely. Attribution appreciated but not required.
