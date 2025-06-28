output "cluster_id" {
  description = "Name/ID of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Kubernetes server version for the cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = aws_eks_cluster.main.platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = aws_eks_cluster.main.status
}

output "cluster_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider if IRSA is enabled"
  value       = var.enable_irsa ? aws_iam_openid_connect_provider.cluster[0].arn : null
}

output "cluster_primary_security_group_id" {
  description = "Cluster primary security group ID"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_iam_role.cluster.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "node_groups" {
  description = "EKS node groups"
  value       = aws_eks_node_group.main
}

output "fargate_profiles" {
  description = "EKS Fargate profiles"
  value       = aws_eks_fargate_profile.main
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = flatten([for group in aws_eks_node_group.main : group.resources[0].autoscaling_groups[*].name])
}

output "node_iam_role_name" {
  description = "IAM role name for EKS node groups"
  value       = aws_iam_role.node.name
}

output "node_iam_role_arn" {
  description = "IAM role ARN for EKS node groups"
  value       = aws_iam_role.node.arn
}

output "fargate_iam_role_name" {
  description = "IAM role name for EKS Fargate profiles"
  value       = length(var.fargate_profiles) > 0 ? aws_iam_role.fargate[0].name : null
}

output "fargate_iam_role_arn" {
  description = "IAM role ARN for EKS Fargate profiles"
  value       = length(var.fargate_profiles) > 0 ? aws_iam_role.fargate[0].arn : null
}