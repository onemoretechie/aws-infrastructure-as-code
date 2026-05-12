variable "name" {
  description = "ALB name (also used as a prefix for the dedicated security group)."
  type        = string

  validation {
    condition     = length(var.name) <= 32
    error_message = "ALB names must be 32 characters or fewer."
  }
}

variable "vpc_id" {
  description = "VPC the ALB lives in."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs the ALB attaches to. Use public subnets for internet-facing, private for internal."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "ALBs require subnets in at least 2 AZs."
  }
}

variable "internal" {
  description = "Whether the load balancer is internal (private) or internet-facing."
  type        = bool
  default     = false
}

variable "ingress_cidr_blocks" {
  description = "CIDRs allowed to reach the ALB's listener ports."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_http_listener" {
  description = "Whether to create the port-80 listener. When TLS is on, this listener redirects to 443."
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ACM certificate ARN to attach to the port-443 listener. Set to enable HTTPS."
  type        = string
  default     = null
}

variable "additional_certificate_arns" {
  description = "Extra ACM certificate ARNs attached to the HTTPS listener (SNI)."
  type        = list(string)
  default     = []
}

variable "ssl_policy" {
  description = "TLS policy on the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "idle_timeout" {
  description = "Idle timeout in seconds."
  type        = number
  default     = 60
}

variable "enable_deletion_protection" {
  description = "Block accidental terraform destroy."
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Whether HTTP/2 is enabled on the load balancer."
  type        = bool
  default     = true
}

variable "drop_invalid_header_fields" {
  description = "Drop HTTP headers with invalid characters (recommended)."
  type        = bool
  default     = true
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs. Null to disable."
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "Key prefix for access logs."
  type        = string
  default     = null
}

variable "default_target_group" {
  description = "Definition of the default target group the listeners forward to. Set port + protocol + health check; targets are registered out-of-band (or by EKS/ASG)."
  type = object({
    port                 = number
    protocol             = optional(string, "HTTP")
    target_type          = optional(string, "ip")
    deregistration_delay = optional(number, 30)
    health_check = optional(object({
      path                = optional(string, "/")
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "HTTP")
      matcher             = optional(string, "200-399")
      interval            = optional(number, 15)
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 2)
      unhealthy_threshold = optional(number, 3)
    }), {})
  })
}

variable "tags" {
  description = "Additional tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}
