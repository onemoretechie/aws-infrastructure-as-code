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
