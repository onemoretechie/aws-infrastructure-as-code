variable "name" {
  description = "Bucket name. Must be globally unique across all of AWS S3."
  type        = string

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 63
    error_message = "Bucket names must be 3 - 63 characters long."
  }
}

variable "force_destroy" {
  description = "Allow Terraform to delete the bucket even if it contains objects. Leave false in prod."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Whether object versioning is enabled."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of a customer-managed KMS key for SSE-KMS encryption. Leave null to use SSE-S3 (AES256)."
  type        = string
  default     = null
}

variable "block_public_access" {
  description = "Whether to block all forms of public access. Should be true unless serving a public website directly from S3."
  type        = bool
  default     = true
}

variable "object_ownership" {
  description = "Object ownership setting. \"BucketOwnerEnforced\" disables ACLs and is the modern default."
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.object_ownership)
    error_message = "object_ownership must be BucketOwnerEnforced, BucketOwnerPreferred, or ObjectWriter."
  }
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules. Each rule needs an id and a set of optional transition/expiration blocks."
  type = list(object({
    id      = string
    enabled = optional(bool, true)
    prefix  = optional(string, "")
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    expiration_days                        = optional(number)
    noncurrent_version_expiration_days     = optional(number)
    abort_incomplete_multipart_upload_days = optional(number)
  }))
  default = []
}

variable "cors_rules" {
  description = "Optional CORS rules. Each rule needs allowed_methods + allowed_origins."
  type = list(object({
    allowed_methods = list(string)
    allowed_origins = list(string)
    allowed_headers = optional(list(string), ["*"])
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, 3000)
  }))
  default = []
}

variable "logging_target_bucket" {
  description = "Bucket name to ship server access logs to. Leave null to disable access logging."
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Key prefix to use when shipping access logs."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}
