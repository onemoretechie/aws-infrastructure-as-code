variable "name" {
  description = "Short name used to derive the KMS key alias (e.g. \"dev-rds\" -> alias/dev-rds)."
  type        = string
}

variable "description" {
  description = "Human-readable description stored on the KMS key."
  type        = string
  default     = "Customer-managed KMS key"
}

variable "deletion_window_in_days" {
  description = "Waiting period before the key is permanently deleted, in days (7 - 30)."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}

variable "enable_key_rotation" {
  description = "Whether AWS-managed annual rotation of the underlying key material is enabled."
  type        = bool
  default     = true
}

variable "key_usage" {
  description = "Cryptographic operations the key supports (ENCRYPT_DECRYPT or SIGN_VERIFY)."
  type        = string
  default     = "ENCRYPT_DECRYPT"

  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY"], var.key_usage)
    error_message = "key_usage must be ENCRYPT_DECRYPT or SIGN_VERIFY."
  }
}

variable "multi_region" {
  description = "Whether to create a multi-region primary key."
  type        = bool
  default     = false
}

variable "service_principals" {
  description = "AWS service principals (e.g. \"rds.amazonaws.com\") granted use of the key via the key policy."
  type        = list(string)
  default     = []
}

variable "additional_principal_arns" {
  description = "Extra IAM principal ARNs (roles, users, accounts) granted full use of the key. The account root is always included."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}
