variable "name" {
  description = "Repository name (e.g. \"sample-web-app\")."
  type        = string
}

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten. \"IMMUTABLE\" is the secure default."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Whether ECR scans every pushed image for vulnerabilities."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of a customer-managed KMS key for image encryption. Leave null to use AES256."
  type        = string
  default     = null
}

variable "force_delete" {
  description = "Allow Terraform to delete the repo even if it contains images. Leave false in prod."
  type        = bool
  default     = false
}

variable "lifecycle_keep_last_n_tagged" {
  description = "How many tagged images to retain per tag prefix. Older tagged images are expired. Set to 0 to disable the rule."
  type        = number
  default     = 30
}

variable "lifecycle_tag_prefixes" {
  description = "Tag prefixes the keep-last-N rule applies to. The \"any\" wildcard rule is implied when this list is empty."
  type        = list(string)
  default     = ["v", "release-"]
}

variable "lifecycle_untagged_expire_days" {
  description = "Days after which untagged images are expired. Set to 0 to disable."
  type        = number
  default     = 7
}

variable "allowed_pull_principal_arns" {
  description = "IAM principal ARNs allowed to pull from this repo. Empty list = repo policy not created (rely on IAM)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}
