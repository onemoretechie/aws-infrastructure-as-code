output "alb_arn" {
  description = "ARN of the load balancer."
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix (the part after the trailing slash) — needed for CloudWatch dimensions."
  value       = aws_lb.this.arn_suffix
}

output "alb_dns_name" {
  description = "DNS name of the load balancer. Front this with a Route53 alias."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID for the ALB. Use as the zone_id of a Route53 alias record."
  value       = aws_lb.this.zone_id
}

output "security_group_id" {
  description = "Security group attached to the ALB. Add it to your target SG's ingress allowlist."
  value       = aws_security_group.this.id
}

output "default_target_group_arn" {
  description = "ARN of the default target group. Register targets against this."
  value       = aws_lb_target_group.default.arn
}

output "http_listener_arn" {
  description = "ARN of the port-80 listener (null if disabled)."
  value       = try(aws_lb_listener.http[0].arn, null)
}

output "https_listener_arn" {
  description = "ARN of the port-443 listener (null if no certificate)."
  value       = try(aws_lb_listener.https[0].arn, null)
}
