output "role_arn" {
  description = "ARN of the IAM role"
  value       = var.create_role ? aws_iam_role.main[0].arn : null
}

output "role_name" {
  description = "Name of the IAM role"
  value       = var.create_role ? aws_iam_role.main[0].name : null
}

output "role_id" {
  description = "ID of the IAM role"
  value       = var.create_role ? aws_iam_role.main[0].unique_id : null
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = var.create_instance_profile && var.create_role ? aws_iam_instance_profile.main[0].arn : null
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = var.create_instance_profile && var.create_role ? aws_iam_instance_profile.main[0].name : null
}

output "user_arn" {
  description = "ARN of the IAM user"
  value       = var.create_user ? aws_iam_user.main[0].arn : null
}

output "user_name" {
  description = "Name of the IAM user"
  value       = var.create_user ? aws_iam_user.main[0].name : null
}

output "access_key_id" {
  description = "Access key ID"
  value       = var.create_user && var.create_access_key ? aws_iam_access_key.main[0].id : null
}

output "secret_access_key" {
  description = "Secret access key"
  value       = var.create_user && var.create_access_key ? aws_iam_access_key.main[0].secret : null
  sensitive   = true
}

output "group_arn" {
  description = "ARN of the IAM group"
  value       = var.create_group ? aws_iam_group.main[0].arn : null
}

output "group_name" {
  description = "Name of the IAM group"
  value       = var.create_group ? aws_iam_group.main[0].name : null
}

output "custom_policy_arns" {
  description = "ARNs of the custom policies created"
  value       = { for k, v in aws_iam_policy.custom : k => v.arn }
}

output "custom_policy_names" {
  description = "Names of the custom policies created"
  value       = { for k, v in aws_iam_policy.custom : k => v.name }
}