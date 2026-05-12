output "cluster_name" {
  description = "Cluster name (echo of input)."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded cluster CA cert — needed by kubectl/Helm to talk to the API."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_version" {
  description = "Kubernetes version of the cluster."
  value       = aws_eks_cluster.this.version
}

output "cluster_security_group_id" {
  description = "Security group EKS created for the cluster control plane."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group attached to the managed node group. Use this for ingress allowlists on RDS/ALB targets."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_role_arn" {
  description = "ARN of the node group IAM role."
  value       = aws_iam_role.node.arn
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider for the cluster. Use as trust_oidc_provider_arn on the iam module for IRSA roles."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "Issuer URL of the OIDC provider (without https://)."
  value       = replace(aws_iam_openid_connect_provider.this.url, "https://", "")
}

output "kubeconfig_command" {
  description = "Command to update your kubeconfig for this cluster."
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region <region>"
}
