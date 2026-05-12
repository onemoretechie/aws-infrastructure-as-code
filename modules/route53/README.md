# module: route53

Hosted zone (public or private) plus a map-driven record set. Use `create_zone = false` to attach records to an existing zone owned elsewhere.

## Usage — public zone + records pointing at an ALB

```hcl
module "dns" {
  source = "../../modules/route53"

  zone_name = "example.com"

  records = {
    "apex-A" = {
      name = "example.com"
      type = "A"
      alias = {
        name                   = module.alb.alb_dns_name
        zone_id                = module.alb.alb_zone_id
        evaluate_target_health = true
      }
    }
    "www-A" = {
      name = "www.example.com"
      type = "A"
      alias = {
        name    = module.alb.alb_dns_name
        zone_id = module.alb.alb_zone_id
      }
    }
  }

  tags = { Environment = "prod" }
}
```

## Usage — internal private zone

```hcl
module "internal_dns" {
  source = "../../modules/route53"

  zone_name            = "internal.example.com"
  private              = true
  private_zone_vpc_ids = [module.vpc.vpc_id]
}
```

## Inputs

See [`variables.tf`](variables.tf).

## Outputs

`zone_id`, `zone_name`, `name_servers` (only when the zone was created here), `record_fqdns`.
