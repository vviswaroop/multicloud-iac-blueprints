output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_hosted_zone_id" {
  description = "RDS instance hosted zone ID"
  value       = aws_db_instance.main.hosted_zone_id
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "RDS instance database name"
  value       = aws_db_instance.main.db_name
}

output "db_instance_username" {
  description = "RDS instance master username"
  value       = aws_db_instance.main.username
}

output "db_instance_password" {
  description = "RDS instance master password"
  value       = aws_db_instance.main.password
  sensitive   = true
}

output "db_instance_engine" {
  description = "RDS instance engine"
  value       = aws_db_instance.main.engine
}

output "db_instance_engine_version" {
  description = "RDS instance engine version"
  value       = aws_db_instance.main.engine_version
}

output "db_instance_class" {
  description = "RDS instance class"
  value       = aws_db_instance.main.instance_class
}

output "db_instance_status" {
  description = "RDS instance status"
  value       = aws_db_instance.main.status
}

output "db_instance_availability_zone" {
  description = "RDS instance availability zone"
  value       = aws_db_instance.main.availability_zone
}

output "db_instance_multi_az" {
  description = "RDS instance Multi-AZ status"
  value       = aws_db_instance.main.multi_az
}

output "db_subnet_group_id" {
  description = "DB subnet group ID"
  value       = var.db_subnet_group_name != "" ? var.db_subnet_group_name : (length(var.subnet_ids) > 0 ? aws_db_subnet_group.main[0].id : null)
}

output "db_parameter_group_id" {
  description = "DB parameter group ID"
  value       = var.parameter_group_name != "" ? var.parameter_group_name : (length(var.parameters) > 0 ? aws_db_parameter_group.main[0].id : null)
}

output "master_user_secret_arn" {
  description = "ARN of the master user secret"
  value       = var.manage_master_user_password ? aws_db_instance.main.master_user_secret[0].secret_arn : null
}