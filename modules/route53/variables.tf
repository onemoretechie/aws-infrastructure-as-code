variable "zone_name" {
  description = "Domain name of the hosted zone (e.g. \"example.com\")."
  type        = string
}

variable "create_zone" {
  description = "Whether to create the hosted zone. Set false to look up an existing one by name."
  type        = bool
  default     = true
}

variable "private" {
  description = "Whether the hosted zone is private (associated with VPCs)."
  type        = bool
  default     = false
}

variable "private_zone_vpc_ids" {
  description = "VPC IDs to associate with the private hosted zone. Ignored when private = false."
  type        = list(string)
  default     = []
}

variable "comment" {
  description = "Comment on the hosted zone."
  type        = string
  default     = "Managed by terraform"
}

variable "records" {
  description = "Map of record key -> record definition. Keyed for stable for_each addressing (e.g. \"www-A\")."
  type = map(object({
    name    = string
    type    = string
    ttl     = optional(number)
    records = optional(list(string))
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, false)
    }))
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags applied to the hosted zone."
  type        = map(string)
  default     = {}
}
