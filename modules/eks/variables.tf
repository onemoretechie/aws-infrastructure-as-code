variable "name" {
  description = "Cluster name (e.g. \"dev-platform\")."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version (e.g. \"1.30\")."
  type        = string
  default     = "1.30"
}

variable "vpc_id" {
  description = "VPC the cluster lives in."
  type        = string
}

variable "control_plane_subnet_ids" {
  description = "Subnets the control plane ENIs land in. Use private subnets."
  type        = list(string)

  validation {
    condition     = length(var.control_plane_subnet_ids) >= 2
    error_message = "EKS requires control plane subnets in at least 2 AZs."
  }
}

variable "node_subnet_ids" {
  description = "Subnets the managed node group launches into. Use private subnets."
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Whether the API server endpoint is reachable from the internet."
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Whether the API server endpoint is reachable from inside the VPC."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to hit the public API endpoint. Tighten in prod."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "kms_key_arn" {
  description = "ARN of a customer-managed KMS key used to encrypt Kubernetes Secrets at rest. Leave null to use AWS-managed encryption."
  type        = string
  default     = null
}

variable "enabled_cluster_log_types" {
  description = "Control plane log types shipped to CloudWatch Logs."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  description = "Retention for the cluster log group in days."
  type        = number
  default     = 30
}

variable "node_group_name" {
  description = "Name of the default managed node group."
  type        = string
  default     = "default"
}

variable "node_instance_types" {
  description = "Instance types the managed node group uses."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_disk_size" {
  description = "Root EBS volume size for each node in GiB."
  type        = number
  default     = 50
}

variable "node_desired_size" {
  description = "Desired node count."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum node count."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum node count."
  type        = number
  default     = 5
}

variable "node_labels" {
  description = "Kubernetes labels applied to the managed node group."
  type        = map(string)
  default     = {}
}

variable "node_taints" {
  description = "Kubernetes taints applied to the managed node group."
  type = list(object({
    key    = string
    value  = optional(string)
    effect = string
  }))
  default = []
}

variable "addons" {
  description = "Managed EKS addons to install. Version null = latest compatible."
  type = map(object({
    version           = optional(string)
    resolve_conflicts = optional(string, "OVERWRITE")
  }))
  default = {
    vpc-cni            = {}
    coredns            = {}
    kube-proxy         = {}
    aws-ebs-csi-driver = {}
  }
}

variable "tags" {
  description = "Additional tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}
