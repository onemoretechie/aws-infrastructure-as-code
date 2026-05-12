# Architecture notes

Diagrams and longer-form notes about the architectural decisions encoded in this repository.

## Module dependency graph

```
                     ┌─────────┐
                     │   vpc   │
                     └────┬────┘
        ┌─────────────────┼─────────────────────┐
        │                 │                     │
        ▼                 ▼                     ▼
   ┌────────┐        ┌────────┐            ┌────────┐
   │  rds   │        │  eks   │────┐       │  alb   │
   └───┬────┘        └───┬────┘    │       └───┬────┘
       │                 │         │           │
       │      ┌──────────┘         │           │
       │      ▼                    ▼           ▼
       │  ┌────────┐           ┌────────┐  ┌────────┐
       │  │  iam   │◀──────────│  ecr   │  │  acm   │
       │  │ (IRSA) │           └────────┘  └───┬────┘
       │  └────────┘                           │
       │                                       │
       ▼                                       ▼
   ┌────────┐                              ┌────────┐
   │  kms   │◀───── used by ────┐          │route53 │
   └────────┘                   │          └────────┘
                                │              ▲
                            ┌───┴────┐         │
                            │   s3   │◀────────┤
                            └────────┘         │
                                               │
                            ┌──────────┐       │
                            │cloudfront│───────┘
                            └──────────┘
                            (uses s3 OR alb origin)
```

## Network topology (per stack)

Each stack composes one VPC across N AZs with three subnet tiers:

```
Internet
   │
   ▼
[ Internet Gateway ]
   │
   ▼
public/AZa  public/AZb  public/AZc   ← ALBs, NAT GWs
   │            │            │
   ▼            ▼            ▼
[ NAT GW ]   [ NAT GW ]   [ NAT GW ]  ← per_az mode; "single" puts one in AZa
   │            │            │
   ▼            ▼            ▼
private/AZa  private/AZb  private/AZc ← EKS nodes, ECS tasks, EC2
   │
   └── no internet egress ───┐
                             ▼
database/AZa  database/AZb  database/AZc ← RDS, ElastiCache
```

Public subnets get an IGW default route, private subnets get a NAT GW default route, database subnets get **no** egress route — they reach RDS via VPC-local traffic only.

## IAM trust patterns

| Use case | `trust_type` | Example |
| --- | --- | --- |
| EC2 instance role | `service` | `trust_service_principals = ["ec2.amazonaws.com"]` |
| Lambda execution role | `service` | `trust_service_principals = ["lambda.amazonaws.com"]` |
| Pod in EKS (IRSA) | `oidc` | `trust_oidc_provider_arn = module.eks.oidc_provider_arn`, `trust_oidc_subjects = ["system:serviceaccount:ns:sa"]` |
| GitHub Actions deploy | `oidc` | `trust_oidc_provider_arn = aws_iam_openid_connect_provider.github.arn`, `trust_oidc_subjects = ["repo:org/repo:ref:refs/heads/main"]` |
| Cross-account access | `aws` | `trust_aws_principals = ["arn:aws:iam::123456789012:root"]` |
| Anything else | `custom` | Pass raw policy JSON via `trust_custom_policy_json`. |

## State + locking

```
                 ┌────────────────────────────┐
                 │  bootstrap/  (run once)    │
                 │  ─ S3 state bucket         │
                 │  ─ DynamoDB lock table     │
                 └─────────────┬──────────────┘
                               │ outputs
                               ▼
            ┌──────────────────────────────────────┐
            │  stacks/*/versions.tf                │
            │    backend "s3" { ... }              │
            └──────────┬───────────────────────────┘
                       │
              ┌────────┴────────┐
              ▼                 ▼
        stacks/dev         stacks/prod
        (own state key)    (own state key)
```

State is partitioned by stack via the `key` attribute of the S3 backend; one DynamoDB table serves locks for all stacks.

## Conventions encoded in the modules

- Every module emits a `Module` tag plus `ManagedBy = "terraform"`, merged with `var.tags` from the caller.
- Resources backed by a single instance are named `aws_<type>.this`; collections use plural or descriptive names.
- All variables have a `description` and validation where the value space is finite.
- Outputs are written from the consumer's perspective — what would you wire into another module?
- KMS encryption is opt-in (`kms_key_arn` nullable) so the modules stay teachable; production stacks pass keys explicitly.
