# module: iam

Reusable IAM role factory. One module call produces one role plus its policy attachments and (optionally) an EC2 instance profile.

## Trust types

| `trust_type` | Used for |
| --- | --- |
| `service` | AWS services like EC2, Lambda, RDS — pass `trust_service_principals = ["ec2.amazonaws.com"]`. |
| `aws` | IAM users/roles/accounts — pass `trust_aws_principals = ["arn:aws:iam::123456789012:root"]`. |
| `oidc` | IRSA (EKS) or GitHub Actions OIDC — pass `trust_oidc_provider_arn` + `trust_oidc_subjects`. |
| `custom` | Anything else — pass a raw policy JSON via `trust_custom_policy_json`. |

## Usage — EC2 instance role

```hcl
module "ec2_role" {
  source = "../../modules/iam"

  name                     = "dev-app-ec2"
  trust_type               = "service"
  trust_service_principals = ["ec2.amazonaws.com"]
  managed_policy_arns      = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  create_instance_profile  = true

  tags = { Environment = "dev" }
}
```

## Usage — IRSA (pod identity in EKS)

```hcl
module "external_dns_role" {
  source = "../../modules/iam"

  name                    = "dev-external-dns"
  trust_type              = "oidc"
  trust_oidc_provider_arn = module.eks.oidc_provider_arn
  trust_oidc_subjects     = ["system:serviceaccount:kube-system:external-dns"]

  inline_policies = {
    route53 = data.aws_iam_policy_document.external_dns.json
  }
}
```

## Inputs

See [`variables.tf`](variables.tf).

## Outputs

`role_name`, `role_arn`, `role_unique_id`, `instance_profile_name`, `instance_profile_arn`.
