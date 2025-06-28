# Network Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "availability_zones" {
  description = "Availability zones used"
  value       = module.vpc.availability_zones
}

# Load Balancer Outputs
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

# Web Tier Outputs
output "web_server_ids" {
  description = "IDs of the web servers"
  value       = [for server in module.web_servers : server.instance_id]
}

output "web_server_private_ips" {
  description = "Private IP addresses of web servers"
  value       = [for server in module.web_servers : server.private_ip]
}

output "web_target_group_arn" {
  description = "ARN of the web target group"
  value       = aws_lb_target_group.web.arn
}

# Database Outputs
output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.db_instance_endpoint
}

output "database_port" {
  description = "RDS instance port"
  value       = module.database.db_instance_port
}

output "database_id" {
  description = "RDS instance ID"
  value       = module.database.db_instance_id
}

output "database_arn" {
  description = "RDS instance ARN"
  value       = module.database.db_instance_arn
}

output "database_master_user_secret_arn" {
  description = "ARN of the database master user secret"
  value       = module.database.master_user_secret_arn
}

# EKS Outputs  
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks_cluster.cluster_id
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks_cluster.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.eks_cluster.cluster_version
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks_cluster.cluster_security_group_id
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for EKS cluster"
  value       = module.eks_cluster.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_oidc_issuer_url" {
  description = "EKS OIDC issuer URL"
  value       = module.eks_cluster.cluster_oidc_issuer_url
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN"
  value       = module.eks_cluster.oidc_provider_arn
}

output "eks_node_groups" {
  description = "EKS node groups"
  value       = module.eks_cluster.node_groups
}

# S3 Outputs
output "app_bucket_id" {
  description = "Application S3 bucket ID"
  value       = module.app_bucket.bucket_id
}

output "app_bucket_arn" {
  description = "Application S3 bucket ARN"
  value       = module.app_bucket.bucket_arn
}

output "app_bucket_domain_name" {
  description = "Application S3 bucket domain name"
  value       = module.app_bucket.bucket_domain_name
}

output "logs_bucket_id" {
  description = "Logs S3 bucket ID"
  value       = module.logs_bucket.bucket_id
}

output "logs_bucket_arn" {
  description = "Logs S3 bucket ARN"
  value       = module.logs_bucket.bucket_arn
}

# IAM Outputs
output "ec2_iam_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = module.ec2_iam_role.role_arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.ec2_iam_role.instance_profile_name
}

output "eks_service_role_arn" {
  description = "ARN of the EKS service role"
  value       = module.eks_service_role.role_arn
}

output "eks_cluster_iam_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = module.eks_cluster.cluster_iam_role_arn
}

output "eks_node_iam_role_arn" {
  description = "ARN of the EKS node IAM role"
  value       = module.eks_cluster.node_iam_role_arn
}

# Bastion Host Outputs
output "bastion_instance_id" {
  description = "ID of the bastion host"
  value       = var.create_bastion ? module.bastion[0].instance_id : null
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = var.create_bastion ? module.bastion[0].public_ip : null
}

output "bastion_public_dns" {
  description = "Public DNS name of the bastion host"
  value       = var.create_bastion ? module.bastion[0].public_dns : null
}

# Application Access Information
output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "kubectl_config_command" {
  description = "Command to configure kubectl for EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks_cluster.cluster_id}"
}

# Connection Information
output "database_connection_info" {
  description = "Database connection information"
  value = {
    endpoint = module.database.db_instance_endpoint
    port     = module.database.db_instance_port
    database = module.database.db_instance_name
    username = module.database.db_instance_username
    secret_arn = module.database.master_user_secret_arn
  }
  sensitive = true
}

output "ssh_commands" {
  description = "SSH commands to connect to instances"
  value = var.create_bastion ? {
    bastion = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${module.bastion[0].public_ip}"
    web_servers = [
      for i, server in module.web_servers : 
      "ssh -i ~/.ssh/${var.key_pair_name}.pem -o ProxyCommand='ssh -i ~/.ssh/${var.key_pair_name}.pem -W %h:%p ec2-user@${module.bastion[0].public_ip}' ec2-user@${server.private_ip}"
    ]
  } : null
}