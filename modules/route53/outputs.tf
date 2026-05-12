output "zone_id" {
  description = "ID of the hosted zone."
  value       = local.zone_id
}

output "zone_name" {
  description = "Name of the hosted zone."
  value       = var.zone_name
}

output "name_servers" {
  description = "Authoritative NS records for the zone. Set these as the delegation at your registrar."
  value       = try(aws_route53_zone.this[0].name_servers, null)
}

output "record_fqdns" {
  description = "Fully-qualified domain names of the records created, keyed by input key."
  value       = { for k, r in aws_route53_record.this : k => r.fqdn }
}
