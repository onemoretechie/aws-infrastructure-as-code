output "vpc_id" {
  description = "ID of the dev VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs in the dev VPC."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs in the dev VPC."
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Database subnet IDs in the dev VPC."
  value       = module.vpc.database_subnet_ids
}
