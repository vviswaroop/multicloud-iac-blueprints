variable "name" {
  description = "Name prefix for RDS resources"
  type        = string
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = ""
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = ""
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = ""
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Master password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "manage_master_user_password" {
  description = "Manage master user password with AWS Secrets Manager"
  type        = bool
  default     = true
}

variable "port" {
  description = "Database port"
  type        = number
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
  default     = []
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
  default     = []
}

variable "parameter_group_name" {
  description = "Name of the DB parameter group"
  type        = string
  default     = ""
}

variable "parameter_group_family" {
  description = "DB parameter group family"
  type        = string
  default     = ""
}

variable "parameters" {
  description = "List of DB parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "option_group_name" {
  description = "Name of the DB option group"
  type        = string
  default     = ""
}

variable "backup_retention_period" {
  description = "Backup retention period"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Make instance publicly accessible"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval"
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "Enhanced monitoring role ARN"
  type        = string
  default     = ""
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period"
  type        = number
  default     = 7
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = []
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting"
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "Final snapshot identifier"
  type        = string
  default     = ""
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshot"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}