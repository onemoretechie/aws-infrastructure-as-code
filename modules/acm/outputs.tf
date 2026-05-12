output "certificate_arn" {
  description = "ARN of the issued certificate. If wait_for_validation = true this is safe to wire into ALB/CloudFront immediately."
  value       = var.wait_for_validation ? aws_acm_certificate_validation.this[0].certificate_arn : aws_acm_certificate.this.arn
}

output "certificate_domain_name" {
  description = "Primary domain on the certificate."
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_status" {
  description = "Current status of the certificate."
  value       = aws_acm_certificate.this.status
}
