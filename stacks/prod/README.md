# stack: prod

Full HA composition that wires together every module in this repository. Stand up an entire vertical — DNS, TLS, CDN, load balancer, EKS, RDS, container registry, encrypted object storage — from one `terraform apply`.

## Architecture

```
                          Internet
                              │
                              ▼
                       CloudFront (CDN)
                       │
                   acm_cloudfront (us-east-1)
                              │
                              ▼
                          ALB :443
                       │
                       acm_alb (regional)
                              │
                              ▼
                 EKS managed node group  ──▶  ECR (sample-web-app)
                       │                     │
                       │ IRSA via OIDC       │
                       ▼                     ▼
                 RDS (Postgres, Multi-AZ)   S3 (assets, logs)
                              │
                       kms_rds / kms_s3 / kms_eks-secrets

VPC: 3 AZs, NAT-per-AZ, VPC Flow Logs to CloudWatch
DNS: Route53 hosted zone for the apex domain + alias records
```

## What it deploys

| Component | Module | Notes |
| --- | --- | --- |
| 3-AZ VPC with flow logs | [`modules/vpc`](../../modules/vpc) | `nat_gateway_mode = "per_az"` for HA egress. |
| 3 customer-managed KMS keys | [`modules/kms`](../../modules/kms) | Per-service keys for S3, RDS, EKS Secrets. |
| Hosted zone + records | [`modules/route53`](../../modules/route53) | Two module calls: zone create, then records (decouples zone existence from records). |
| ACM cert (regional) | [`modules/acm`](../../modules/acm) | For the ALB. |
| ACM cert (us-east-1) | [`modules/acm`](../../modules/acm) (aliased provider) | For CloudFront. |
| Two S3 buckets (logs + assets) | [`modules/s3`](../../modules/s3) | SSE-KMS, lifecycle to Glacier on logs. |
| ECR repo | [`modules/ecr`](../../modules/ecr) | Immutable tags, scan-on-push. |
| RDS Postgres Multi-AZ | [`modules/rds`](../../modules/rds) | 14-day backups, deletion protection on, ingress from EKS node SG. |
| EKS cluster + node group | [`modules/eks`](../../modules/eks) | Secrets envelope-encrypted with KMS, OIDC provider published. |
| ALB | [`modules/alb`](../../modules/alb) | HTTPS listener, deletion protection on. |
| CloudFront distribution | [`modules/cloudfront`](../../modules/cloudfront) | Custom origin = ALB. |

## Required inputs

```hcl
# stacks/prod/terraform.tfvars (don't commit)
bucket_name_prefix = "myco"
domain_name        = "example.com"
```

If the hosted zone already exists outside this stack, set `create_dns_zone = false` and the module will look it up by name.

## Usage

```bash
cd stacks/prod
terraform init
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

After apply:

1. If the zone was newly created, set the `route53_name_servers` output as the delegation at your registrar.
2. `aws eks update-kubeconfig --name prod-platform --region <region>` and `kubectl get nodes` to verify the cluster.
3. Pull RDS credentials from Secrets Manager using `rds_master_user_secret_arn`.

## Things to know

- **CloudFront cert provider.** CloudFront only accepts certs from `us-east-1`. This stack declares two AWS providers and passes the aliased one to `module.acm_cloudfront`.
- **DNS bootstrap.** The hosted zone is created in `module.dns` and the alias records in `module.dns_records`. Splitting them lets ACM write its validation records into the same zone without a circular dependency.
- **State.** Configure the `backend "s3"` block in [`versions.tf`](versions.tf) before the first `terraform init` — output of [bootstrap](../../bootstrap/README.md).
