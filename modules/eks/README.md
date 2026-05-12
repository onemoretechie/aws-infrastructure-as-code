# module: eks

EKS cluster with one managed node group, IRSA (OIDC provider) wired up, control-plane logging on, and a default set of managed addons.

## Features

- Cluster IAM role + node IAM role pre-attached with the right managed policies.
- OIDC provider published; pair with the `iam` module (`trust_type = "oidc"`) to create IRSA roles for pods.
- Optional KMS envelope encryption of Kubernetes Secrets when `kms_key_arn` is set.
- Control-plane logs shipped to CloudWatch Logs with a per-cluster retention period.
- Managed node group with configurable instance types, scaling, labels, taints, and ON_DEMAND/SPOT capacity.
- Default addons: `vpc-cni`, `coredns`, `kube-proxy`, `aws-ebs-csi-driver`. Override via the `addons` map.

## Usage

```hcl
module "eks" {
  source = "../../modules/eks"

  name               = "dev-platform"
  kubernetes_version = "1.30"

  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.private_subnet_ids
  node_subnet_ids          = module.vpc.private_subnet_ids

  kms_key_arn = module.kms_eks.key_arn

  node_instance_types = ["t3.medium"]
  node_desired_size   = 2
  node_min_size       = 1
  node_max_size       = 5

  tags = { Environment = "dev" }
}
```

After apply, `aws eks update-kubeconfig --name dev-platform --region <region>` to point kubectl at it.

## IRSA pattern

```hcl
module "external_dns_role" {
  source = "../../modules/iam"

  name                    = "dev-external-dns"
  trust_type              = "oidc"
  trust_oidc_provider_arn = module.eks.oidc_provider_arn
  trust_oidc_subjects     = ["system:serviceaccount:kube-system:external-dns"]
  inline_policies         = { route53 = local.external_dns_policy_json }
}
```

## Inputs

See [`variables.tf`](variables.tf).

## Outputs

`cluster_name`, `cluster_endpoint`, `cluster_certificate_authority_data`, `cluster_security_group_id`, `node_role_arn`, `oidc_provider_arn`, `oidc_provider_url`.
