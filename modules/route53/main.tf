locals {
  base_tags = merge(
    {
      Module    = "route53"
      ManagedBy = "terraform"
    },
    var.tags,
  )
}

resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0

  name    = var.zone_name
  comment = var.comment

  dynamic "vpc" {
    for_each = var.private ? toset(var.private_zone_vpc_ids) : toset([])
    content {
      vpc_id = vpc.value
    }
  }

  tags = merge(local.base_tags, { Name = var.zone_name })
}

data "aws_route53_zone" "lookup" {
  count = var.create_zone ? 0 : 1

  name         = var.zone_name
  private_zone = var.private
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.lookup[0].zone_id
}

resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id = local.zone_id
  name    = each.value.name
  type    = each.value.type

  ttl     = each.value.alias == null ? each.value.ttl : null
  records = each.value.alias == null ? each.value.records : null

  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }
}
