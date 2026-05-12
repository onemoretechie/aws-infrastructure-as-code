# Tutorial index

Each row maps a tutorial episode to the code that ships with it. Episodes are designed to be watched in order — later ones reuse outputs from earlier modules.

| # | Topic | Code |
| - | --- | --- |
| 01 | Remote state on S3 + DynamoDB lock | [`bootstrap/`](../../bootstrap/) |
| 02 | A reusable VPC module from first principles | [`modules/vpc/`](../../modules/vpc/) |
| 03 | Customer-managed KMS keys and how to wire them everywhere | [`modules/kms/`](../../modules/kms/) |
| 04 | Hardened S3 buckets (encryption, versioning, lifecycle) | [`modules/s3/`](../../modules/s3/) |
| 05 | A reusable IAM role factory (service / aws / OIDC / custom trust) | [`modules/iam/`](../../modules/iam/) |
| 06 | Container registries done right (immutable tags, lifecycle, scan-on-push) | [`modules/ecr/`](../../modules/ecr/) |
| 07 | RDS PostgreSQL in isolated subnets with Secrets-Manager-managed credentials | [`modules/rds/`](../../modules/rds/) |
| 08 | Composing modules into a low-cost dev environment | [`stacks/dev/`](../../stacks/dev/) |
| 09 | Route53 hosted zones and the chicken-and-egg of ACM DNS validation | [`modules/route53/`](../../modules/route53/) + [`modules/acm/`](../../modules/acm/) |
| 10 | Application Load Balancers with auto-redirect to HTTPS | [`modules/alb/`](../../modules/alb/) |
| 11 | EKS with managed node groups, IRSA, and KMS-encrypted secrets | [`modules/eks/`](../../modules/eks/) |
| 12 | CloudFront in front of S3 (OAC) and in front of an ALB | [`modules/cloudfront/`](../../modules/cloudfront/) |
| 13 | Promoting dev to prod: multi-AZ, deletion protection, cross-region certs | [`stacks/prod/`](../../stacks/prod/) |

## Errata

When episode code drifts from what's in this repository, that's a sign the module evolved after the episode was published — the current `main` reflects the canonical shape. Open an issue if you spot a divergence the episode notes haven't covered.
