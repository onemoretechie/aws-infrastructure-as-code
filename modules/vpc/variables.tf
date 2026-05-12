variable "name" {
  description = "Short name used as a prefix for all VPC resources (e.g. \"dev\", \"prod\")."
  type        = string
}

variable "cidr_block" {
  description = "Primary IPv4 CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.cidr_block))
    error_message = "cidr_block must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of AZs to spread subnets across. At least 2 recommended for HA."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 1
    error_message = "At least one availability zone is required."
  }
}

variable "public_subnet_newbits" {
  description = "Bits to add to the VPC CIDR for public subnets (e.g. /16 + 4 = /20)."
  type        = number
  default     = 4
}

variable "private_subnet_newbits" {
  description = "Bits to add to the VPC CIDR for private subnets."
  type        = number
  default     = 4
}

variable "database_subnet_newbits" {
  description = "Bits to add to the VPC CIDR for database subnets."
  type        = number
  default     = 8
}

variable "nat_gateway_mode" {
  description = "How NAT Gateways are provisioned: \"per_az\" (HA), \"single\" (cheap), or \"none\"."
  type        = string
  default     = "single"

  validation {
    condition     = contains(["per_az", "single", "none"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be one of: per_az, single, none."
  }
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs to CloudWatch Logs."
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "Retention period for the VPC Flow Logs log group, in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}
