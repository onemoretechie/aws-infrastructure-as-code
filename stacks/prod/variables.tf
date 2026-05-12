variable "aws_region" {
  description = "Primary AWS region this stack deploys into."
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "Primary CIDR block for the prod VPC."
  type        = string
  default     = "10.30.0.0/16"
}

variable "availability_zones" {
  description = "AZs the prod VPC is spread across (3 recommended)."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "bucket_name_prefix" {
  description = "Prefix used to make S3 bucket names globally unique. Required."
  type        = string
}

variable "domain_name" {
  description = "Apex domain managed in Route53 (e.g. \"example.com\"). Required."
  type        = string
}

variable "create_dns_zone" {
  description = "Whether to create the Route53 hosted zone in this stack. Set false if the zone already exists elsewhere."
  type        = bool
  default     = true
}

variable "app_subdomain" {
  description = "Subdomain (left of the apex) the ALB-backed app is exposed on."
  type        = string
  default     = "app"
}

variable "cdn_subdomain" {
  description = "Subdomain the CloudFront distribution serves."
  type        = string
  default     = "www"
}

variable "kubernetes_version" {
  description = "EKS minor version."
  type        = string
  default     = "1.30"
}

variable "rds_engine_version" {
  description = "Postgres engine version."
  type        = string
  default     = "16.3"
}

variable "rds_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.m6g.large"
}

variable "node_instance_types" {
  description = "EKS managed node group instance types."
  type        = list(string)
  default     = ["m6i.large"]
}

variable "node_desired_size" {
  description = "Desired EKS node count."
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum EKS node count."
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum EKS node count."
  type        = number
  default     = 10
}
