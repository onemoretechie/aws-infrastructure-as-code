# bootstrap

Creates the Terraform remote-state backend for every other stack in this repository:

- An S3 bucket for state files (versioned, encrypted, public-access blocked).
- A DynamoDB table for state locking.

Run this **once per AWS account** before applying any stack. The bootstrap stack itself uses local state — there is no chicken-and-egg problem.

## Usage

```bash
cd bootstrap
terraform init
terraform apply -var="state_bucket_name=<globally-unique-bucket-name>"
```

The outputs print the exact `backend "s3"` block to paste into each stack's `versions.tf`.

## Inputs

| Name | Description | Default |
| --- | --- | --- |
| `state_bucket_name` | Globally unique S3 bucket name for Terraform state. | — (required) |
| `lock_table_name` | DynamoDB table name for state locking. | `terraform-state-lock` |
| `aws_region` | AWS region for backend resources. | `ap-south-1` |

## Notes

- The S3 bucket has **`prevent_destroy = true`** — deleting it requires removing that lifecycle block first. This is intentional; losing the state bucket means losing every stack's state.
- Object Lock is not enabled by default to keep costs down; enable it for production-grade compliance environments.
