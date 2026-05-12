output "distribution_id" {
  description = "ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "ARN of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.arn
}

output "domain_name" {
  description = "Default *.cloudfront.net domain. Front it with a Route53 alias on your alias names."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "hosted_zone_id" {
  description = "CloudFront's hosted zone ID — use as zone_id of a Route53 alias record (always Z2FDTNDATAQYW2)."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "origin_access_control_id" {
  description = "ID of the OAC (null if not an S3 origin)."
  value       = try(aws_cloudfront_origin_access_control.this[0].id, null)
}
