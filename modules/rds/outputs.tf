output "instance_id" {
  description = "Identifier of the RDS instance."
  value       = aws_db_instance.this.id
}

output "instance_arn" {
  description = "ARN of the RDS instance."
  value       = aws_db_instance.this.arn
}

output "endpoint" {
  description = "Connection endpoint (host:port)."
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "Hostname only (no port)."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "TCP port the engine is listening on."
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Initial database name (null if none was set)."
  value       = aws_db_instance.this.db_name
}

output "master_username" {
  description = "Master user name."
  value       = aws_db_instance.this.username
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the master password (null if manage_master_password is false)."
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}

output "security_group_id" {
  description = "Security group ID that fronts the database. Attach this to clients or add it to allowed_security_group_ids on dependents."
  value       = aws_security_group.this.id
}

output "subnet_group_name" {
  description = "Name of the DB subnet group used by the instance."
  value       = aws_db_subnet_group.this.name
}
