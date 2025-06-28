output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.main.arn
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = aws_instance.main.instance_state
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.main.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.main.private_ip
}

output "public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.main.public_dns
}

output "private_dns" {
  description = "Private DNS name of the instance"
  value       = aws_instance.main.private_dns
}

output "security_group_id" {
  description = "ID of the security group created (if any)"
  value       = var.create_security_group ? aws_security_group.main[0].id : null
}

output "security_group_arn" {
  description = "ARN of the security group created (if any)"
  value       = var.create_security_group ? aws_security_group.main[0].arn : null
}

output "ami_id" {
  description = "AMI ID used for the instance"
  value       = local.ami_id
}

output "availability_zone" {
  description = "Availability zone of the instance"
  value       = aws_instance.main.availability_zone
}

output "subnet_id" {
  description = "Subnet ID of the instance"
  value       = aws_instance.main.subnet_id
}

output "vpc_id" {
  description = "VPC ID of the instance"
  value       = data.aws_subnet.selected.vpc_id
}