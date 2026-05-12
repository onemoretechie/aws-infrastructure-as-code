variable "name" {
  description = "Friendly name (used as the distribution comment and on tags)."
  type        = string
}

variable "aliases" {
  description = "Alternate domain names (CNAMEs) the distribution serves. Requires a matching us-east-1 ACM cert."
  type        = list(string)
  default     = []
}

variable "certificate_arn" {
  description = "ARN of an ACM certificate in us-east-1 covering all aliases. Leave null to use the default *.cloudfront.net certificate."
  type        = string
  default     = null
}

variable "minimum_protocol_version" {
  description = "Minimum TLS version. Ignored when certificate_arn is null."
  type        = string
  default     = "TLSv1.2_2021"
}

variable "price_class" {
  description = "PriceClass_All, PriceClass_200, or PriceClass_100."
  type        = string
  default     = "PriceClass_100"
}

variable "default_root_object" {
  description = "Object returned for requests to / (e.g. \"index.html\")."
  type        = string
  default     = null
}

variable "comment" {
  description = "Distribution comment."
  type        = string
  default     = null
}

variable "logging" {
  description = "Optional access logging configuration."
  type = object({
    bucket          = string
    prefix          = optional(string, "")
    include_cookies = optional(bool, false)
  })
  default = null
}

variable "web_acl_id" {
  description = "ARN of a WAFv2 web ACL (must be in us-east-1 / CLOUDFRONT scope) to attach. Null to skip."
  type        = string
  default     = null
}

variable "s3_origin" {
  description = "S3 bucket origin. Set this OR custom_origin, not both."
  type = object({
    bucket_regional_domain_name = string
    bucket_arn                  = string
    origin_path                 = optional(string, "")
  })
  default = null
}

variable "custom_origin" {
  description = "Custom HTTP origin (e.g. an ALB DNS name). Set this OR s3_origin, not both."
  type = object({
    domain_name              = string
    origin_path              = optional(string, "")
    http_port                = optional(number, 80)
    https_port               = optional(number, 443)
    origin_protocol_policy   = optional(string, "https-only")
    origin_ssl_protocols     = optional(list(string), ["TLSv1.2"])
    origin_read_timeout      = optional(number, 30)
    origin_keepalive_timeout = optional(number, 5)
    custom_headers           = optional(map(string), {})
  })
  default = null
}

variable "default_cache_behavior" {
  description = "Cache behavior for the default path pattern (*)."
  type = object({
    allowed_methods            = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods             = optional(list(string), ["GET", "HEAD"])
    viewer_protocol_policy     = optional(string, "redirect-to-https")
    compress                   = optional(bool, true)
    cache_policy_id            = optional(string)
    origin_request_policy_id   = optional(string)
    response_headers_policy_id = optional(string)
  })
  default = {}
}

variable "geo_restriction" {
  description = "Geo restriction: \"none\", \"whitelist\", or \"blacklist\" with locations."
  type = object({
    restriction_type = string
    locations        = optional(list(string), [])
  })
  default = {
    restriction_type = "none"
  }
}

variable "tags" {
  description = "Additional tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}
