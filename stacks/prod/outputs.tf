output "vpc_id" {
  description = "ID of the prod VPC."
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the prod ALB. Records are aliased from the app FQDN."
  value       = module.alb.alb_dns_name
}

output "cloudfront_domain_name" {
  description = "Default cloudfront.net domain for the prod CDN."
  value       = module.cloudfront.domain_name
}

output "app_url" {
  description = "Direct URL of the app behind the ALB."
  value       = "https://${local.app_fqdn}"
}

output "cdn_url" {
  description = "Public URL served by CloudFront."
  value       = "https://${local.cdn_fqdn}"
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_kubeconfig_command" {
  description = "Command to update kubeconfig for the prod cluster."
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

output "ecr_app_repository_url" {
  description = "ECR repo URL for sample-web-app."
  value       = module.ecr_app.repository_url
}

output "rds_endpoint" {
  description = "RDS connection endpoint."
  value       = module.rds.endpoint
}

output "rds_master_user_secret_arn" {
  description = "Secrets Manager ARN with the RDS master password."
  value       = module.rds.master_user_secret_arn
}

output "logs_bucket_name" {
  description = "Centralized logs bucket."
  value       = module.logs_bucket.bucket_id
}

output "assets_bucket_name" {
  description = "Static-assets bucket fronted by CloudFront."
  value       = module.assets_bucket.bucket_id
}

output "route53_name_servers" {
  description = "Authoritative NS records for the hosted zone (null if create_dns_zone = false)."
  value       = module.dns.name_servers
}
