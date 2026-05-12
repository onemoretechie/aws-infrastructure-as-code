output "state_bucket_name" {
  description = "S3 bucket holding Terraform state files."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state bucket."
  value       = aws_s3_bucket.state.arn
}

output "lock_table_name" {
  description = "DynamoDB table used for state locking."
  value       = aws_dynamodb_table.lock.name
}

output "backend_config_snippet" {
  description = "Drop-in backend block for each stack's versions.tf. Replace <key> with a per-stack path, e.g. stacks/dev/terraform.tfstate."
  value       = <<-EOT
    backend "s3" {
      bucket         = "${aws_s3_bucket.state.id}"
      key            = "<key>"
      region         = "${var.aws_region}"
      dynamodb_table = "${aws_dynamodb_table.lock.name}"
      encrypt        = true
    }
  EOT
}
