variable "name" {
  description = "Name of the IAM role."
  type        = string
}

variable "path" {
  description = "IAM path. Useful for namespacing service-owned roles."
  type        = string
  default     = "/"
}

variable "description" {
  description = "Human-readable description of the role's purpose."
  type        = string
  default     = null
}

variable "trust_type" {
  description = "Source of the assume-role trust policy. \"service\" for AWS services, \"aws\" for IAM principals, \"oidc\" for IRSA/GitHub OIDC, \"custom\" for a raw policy JSON."
  type        = string
  default     = "service"

  validation {
    condition     = contains(["service", "aws", "oidc", "custom"], var.trust_type)
    error_message = "trust_type must be one of: service, aws, oidc, custom."
  }
}

variable "trust_service_principals" {
  description = "AWS service principals trusted to assume the role (e.g. [\"ec2.amazonaws.com\"]). Used when trust_type = service."
  type        = list(string)
  default     = []
}

variable "trust_aws_principals" {
  description = "IAM principal ARNs trusted to assume the role. Used when trust_type = aws."
  type        = list(string)
  default     = []
}

variable "trust_oidc_provider_arn" {
  description = "OIDC provider ARN trusted to assume the role. Used when trust_type = oidc."
  type        = string
  default     = null
}

variable "trust_oidc_audience" {
  description = "Expected audience claim (e.g. \"sts.amazonaws.com\" for IRSA)."
  type        = string
  default     = "sts.amazonaws.com"
}

variable "trust_oidc_subjects" {
  description = "Subjects (sub claim) allowed to assume the role. For IRSA: [\"system:serviceaccount:<ns>:<sa>\"]."
  type        = list(string)
  default     = []
}

variable "trust_custom_policy_json" {
  description = "Raw assume-role policy JSON. Used when trust_type = custom."
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "AWS-managed or customer-managed policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy name -> policy JSON. Inline policies travel with the role and are deleted with it."
  type        = map(string)
  default     = {}
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) when this role is assumed. 3600 - 43200."
  type        = number
  default     = 3600
}

variable "permissions_boundary_arn" {
  description = "Optional permissions boundary policy ARN."
  type        = string
  default     = null
}

variable "create_instance_profile" {
  description = "Whether to also create an EC2 instance profile wrapping this role."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}
