variable "aws_region" {
  description = "AWS region where the state bucket and lock table are created."
  type        = string
  default     = "ap-south-1"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name must be a valid S3 bucket name (lowercase, 3-63 chars)."
  }
}

variable "lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking."
  type        = string
  default     = "terraform-state-lock"
}
