# module: alb

Application Load Balancer with its own security group, a default target group, and listeners that do the right thing whether or not TLS is configured.

## Behavior

- When `certificate_arn` is **not** set: a single HTTP listener on port 80 forwards to the default target group.
- When `certificate_arn` **is** set: port 80 redirects to 443, and port 443 terminates TLS with the cert and forwards to the default target group.
- The security group accepts traffic from `ingress_cidr_blocks` (default `0.0.0.0/0`) and egresses anywhere — you allow it on your target's SG.

## Usage

```hcl
module "alb" {
  source = "../../modules/alb"

  name       = "dev-edge"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  certificate_arn = module.acm_edge.certificate_arn

  default_target_group = {
    port = 8080
    health_check = {
      path     = "/healthz"
      interval = 10
    }
  }

  tags = { Environment = "dev" }
}
```

## Inputs

See [`variables.tf`](variables.tf).

## Outputs

`alb_arn`, `alb_dns_name`, `alb_zone_id`, `security_group_id`, `default_target_group_arn`, `https_listener_arn`.
