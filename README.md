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
| [`modules/`](modules/) | Reusable building blocks — VPC, EKS, RDS, IAM, S3, CloudFront. |
| [`stacks/`](stacks/) | Environment-scoped compositions (`dev`, `prod`) that wire modules together. |
| [`docs/`](docs/) | Architecture diagrams and tutorial companion notes. |

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
