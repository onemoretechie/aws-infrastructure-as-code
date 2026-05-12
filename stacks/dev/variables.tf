variable "aws_region" {
  description = "AWS region this stack deploys into."
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "Primary CIDR block for the dev VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "AZs the dev VPC is spread across."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "bucket_name_prefix" {
  description = "Prefix used to make S3 bucket names globally unique (e.g. \"omt\" -> \"omt-dev-uploads\"). Required."
  type        = string
}

variable "enable_rds" {
  description = "Whether the dev stack provisions a small RDS instance. Off by default to keep cost low."
  type        = bool
  default     = false
}

variable "rds_engine_version" {
  description = "Postgres engine version when enable_rds = true."
  type        = string
  default     = "16.3"
}
