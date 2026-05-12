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

output "uploads_bucket_name" {
  description = "Name of the dev uploads bucket."
  value       = module.uploads_bucket.bucket_id
}

output "ecr_app_repository_url" {
  description = "ECR repo URL for sample-web-app. Use this in `docker push`."
  value       = module.ecr_app.repository_url
}

output "ec2_instance_profile_name" {
  description = "Instance profile to attach to dev EC2 instances for SSM-managed access."
  value       = module.ec2_role.instance_profile_name
}

output "rds_endpoint" {
  description = "RDS connection endpoint (null when enable_rds = false)."
  value       = try(module.rds[0].endpoint, null)
}

output "rds_master_user_secret_arn" {
  description = "Secrets Manager ARN holding the RDS master password (null when enable_rds = false)."
  value       = try(module.rds[0].master_user_secret_arn, null)
}
