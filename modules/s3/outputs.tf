output "bucket_id" {
  description = "Name of the bucket (same as the input \"name\")."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Regional domain name of the bucket. Use this as a CloudFront origin."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "Route53 hosted zone ID for the bucket (region-specific)."
  value       = aws_s3_bucket.this.hosted_zone_id
}
