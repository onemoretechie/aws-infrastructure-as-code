# module: kms

Customer-managed KMS key with an alias, annual rotation, and a generated key policy that grants:

- the account root full administrative access (so IAM policies can govern further use),
- optional AWS service principals (e.g. `rds.amazonaws.com`, `s3.amazonaws.com`) the data plane permissions they need,
- optional extra IAM principals (cross-account, specific roles) the standard encrypt/decrypt set.

## Usage

```hcl
module "kms_rds" {
  source = "../../modules/kms"

  name               = "dev-rds"
  description        = "Encrypts dev RDS storage + snapshots"
  service_principals = ["rds.amazonaws.com"]

  tags = { Environment = "dev" }
}
```

## Inputs

See [`variables.tf`](variables.tf).

## Outputs

`key_id`, `key_arn`, `alias_name`, `alias_arn`. Pass `key_arn` into other modules' `kms_key_arn` inputs.
