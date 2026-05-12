variable "name" {
  description = "Identifier for the RDS instance (e.g. \"dev-app\")."
  type        = string
}

variable "engine" {
  description = "Database engine. \"postgres\" or \"mysql\"."
  type        = string

  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "engine must be \"postgres\" or \"mysql\"."
  }
}

variable "engine_version" {
  description = "Engine version (e.g. \"16.3\" for postgres, \"8.0.39\" for mysql)."
  type        = string
}

variable "instance_class" {
  description = "Instance class (e.g. \"db.t4g.micro\", \"db.m6g.large\")."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial storage size in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper bound for storage autoscaling. Set equal to allocated_storage to disable autoscaling."
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type: gp3, gp2, or io1."
  type        = string
  default     = "gp3"
}

variable "kms_key_arn" {
  description = "ARN of a customer-managed KMS key for storage encryption. Leave null to use the AWS-managed default RDS key."
  type        = string
  default     = null
}

variable "database_name" {
  description = "Initial database name. For postgres this also becomes the default DB."
  type        = string
  default     = null
}

variable "master_username" {
  description = "Master user name. Generated as \"<engine>admin\" if null."
  type        = string
  default     = null
}

variable "manage_master_password" {
  description = "Let RDS generate and rotate the master password in Secrets Manager. Recommended."
  type        = bool
  default     = true
}

variable "master_password" {
  description = "Master password. Only used when manage_master_password = false. Avoid passing this in code — read from a Secrets Manager data source instead."
  type        = string
  default     = null
  sensitive   = true
}

variable "port" {
  description = "TCP port. Defaults to engine standard (5432 / 3306)."
  type        = number
  default     = null
}

variable "vpc_id" {
  description = "VPC the instance lives in. Used to scope the security group."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group. Use the VPC module's database_subnet_ids."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "RDS DB subnet groups require subnets in at least 2 AZs."
  }
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to the database."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database. Prefer SG references over CIDR allowlists."
  type        = list(string)
  default     = []
}

variable "multi_az" {
  description = "Whether to provision a standby in another AZ for HA."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the instance is internet-routable. Should be false."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Days to retain automated backups (0 - 35). 0 disables backups."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Daily UTC window for automated backups, format \"hh24:mi-hh24:mi\"."
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Weekly UTC window for engine maintenance, format \"ddd:hh24:mi-ddd:hh24:mi\"."
  type        = string
  default     = "sun:04:30-sun:05:30"
}

variable "deletion_protection" {
  description = "Block accidental terraform destroy. Set false in dev, true in prod."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot on delete. Should be false in prod."
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0 disables it). Valid: 0, 1, 5, 10, 15, 30, 60."
  type        = number
  default     = 60
}

variable "parameter_group_parameters" {
  description = "Custom DB parameter overrides (name -> value). Applied to a parameter group dedicated to this instance."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}
