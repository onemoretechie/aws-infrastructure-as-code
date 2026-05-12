# module: rds

Single RDS instance for PostgreSQL or MySQL, hardened for production defaults.

## Features

- Storage always encrypted (AWS-managed key by default, customer-managed KMS key when `kms_key_arn` is set).
- Lives in the database subnet group built from your VPC's isolated subnets — no public IP.
- Engine-aware defaults: port (5432 / 3306), parameter group family, default master username.
- Master password generated and rotated by RDS in Secrets Manager (`manage_master_password = true` by default).
- Dedicated parameter group so engine tunables are versioned with the instance.
- Dedicated security group that ingresses only from the SG IDs / CIDRs you allow.
- Enhanced monitoring + Performance Insights on by default.
- Deletion protection on by default; opt out per-stack for dev.
- Automated backups (7 days) + maintenance/backup windows in UTC.

## Usage

```hcl
module "rds" {
  source = "../../modules/rds"

  name           = "dev-app"
  engine         = "postgres"
  engine_version = "16.3"
  instance_class = "db.t4g.micro"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.database_subnet_ids

  allowed_security_group_ids = [module.eks.node_security_group_id]

  kms_key_arn         = module.kms_rds.key_arn
  database_name       = "app"
  multi_az            = false
  deletion_protection = false  # dev only

  tags = { Environment = "dev" }
}
```

After apply, fetch the master credentials from Secrets Manager using the `master_user_secret_arn` output.

## Inputs

See [`variables.tf`](variables.tf).

## Outputs

`endpoint`, `address`, `port`, `database_name`, `master_username`, `master_user_secret_arn`, `security_group_id`, etc.
