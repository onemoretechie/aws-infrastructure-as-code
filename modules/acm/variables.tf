variable "domain_name" {
  description = "Primary domain name on the certificate (e.g. \"www.example.com\")."
  type        = string
}

variable "subject_alternative_names" {
  description = "Extra SANs (e.g. [\"example.com\", \"*.example.com\"])."
  type        = list(string)
  default     = []
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID to write DNS validation records into. All domains on the cert must live in this zone."
  type        = string
}

variable "wait_for_validation" {
  description = "Whether to block the apply until ACM has issued the certificate."
  type        = bool
  default     = true
}

variable "validation_record_ttl" {
  description = "TTL for the CNAME validation records."
  type        = number
  default     = 60
}

variable "tags" {
  description = "Additional tags applied to the certificate."
  type        = map(string)
  default     = {}
}
