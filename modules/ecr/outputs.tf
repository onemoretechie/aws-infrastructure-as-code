output "repository_name" {
  description = "Repository name (echo of input)."
  value       = aws_ecr_repository.this.name
}

output "repository_arn" {
  description = "ARN of the repository."
  value       = aws_ecr_repository.this.arn
}

output "repository_url" {
  description = "Repository URL used by `docker push` / `docker pull`."
  value       = aws_ecr_repository.this.repository_url
}

output "registry_id" {
  description = "AWS account ID that owns the repo (the registry ID)."
  value       = aws_ecr_repository.this.registry_id
}
