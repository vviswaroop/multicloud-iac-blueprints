# GCP CloudSQL Module - Variables

# Required Variables
variable "project_id" {
  description = "The project ID to host the database"
  type        = string
}

variable "instance_name" {
  description = "The name of the database instance"
  type        = string
}

variable "database_version" {
  description = "The database version to use"
  type        = string
  validation {
    condition = contains([
      "POSTGRES_13", "POSTGRES_14", "POSTGRES_15", "POSTGRES_16",
      "MYSQL_5_7", "MYSQL_8_0",
      "SQLSERVER_2019_STANDARD", "SQLSERVER_2019_ENTERPRISE", "SQLSERVER_2019_EXPRESS", "SQLSERVER_2019_WEB",
      "SQLSERVER_2022_STANDARD", "SQLSERVER_2022_ENTERPRISE", "SQLSERVER_2022_EXPRESS", "SQLSERVER_2022_WEB"
    ], var.database_version)
    error_message = "Database version must be a valid Cloud SQL database version."
  }
}

variable "region" {
  description = "The region to host the database"
  type        = string
}

# Instance Configuration
variable "tier" {
  description = "The machine type to use for the database instance"
  type        = string
  default     = "db-n1-standard-1"
}

variable "availability_type" {
  description = "The availability type for the master instance. Can be ZONAL or REGIONAL"
  type        = string
  default     = "ZONAL"
  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "Availability type must be either ZONAL or REGIONAL."
  }
}

variable "disk_size" {
  description = "The disk size for the master instance"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "The disk type for the master instance"
  type        = string
  default     = "PD_SSD"
  validation {
    condition     = contains(["PD_SSD", "PD_HDD"], var.disk_type)
    error_message = "Disk type must be either PD_SSD or PD_HDD."
  }
}

variable "disk_autoresize" {
  description = "Configuration to increase storage size automatically"
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  description = "The maximum size to which storage can be auto increased"
  type        = number
  default     = 0
}

variable "deletion_protection" {
  description = "Used to block Terraform from deleting a SQL Instance"
  type        = bool
  default     = true
}

variable "user_labels" {
  description = "The key/value labels for the master instances"
  type        = map(string)
  default     = {}
}

# Database Flags
variable "database_flags" {
  description = "List of Cloud SQL flags that are applied to the database server"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# Backup Configuration
variable "backup_enabled" {
  description = "True if backup configuration is enabled"
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "HH:MM format time indicating when backup configuration starts"
  type        = string
  default     = "20:55"
}

variable "backup_location" {
  description = "The region where the backup will be stored"
  type        = string
  default     = null
}

variable "point_in_time_recovery_enabled" {
  description = "True if Point-in-time recovery is enabled"
  type        = bool
  default     = true
}

variable "transaction_log_retention_days" {
  description = "The number of days of transaction logs we retain for point in time restore"
  type        = number
  default     = 7
}

variable "backup_retained_backups" {
  description = "Depending on the value of retention_unit, this is used to determine if a backup needs to be deleted"
  type        = number
  default     = 7
}

variable "backup_retention_unit" {
  description = "The unit that 'retained_backups' represents"
  type        = string
  default     = "COUNT"
  validation {
    condition     = contains(["COUNT"], var.backup_retention_unit)
    error_message = "Backup retention unit must be COUNT."
  }
}

# Maintenance Window
variable "maintenance_window_day" {
  description = "The day of week (1-7) for the master instance maintenance"
  type        = number
  default     = 1
  validation {
    condition     = var.maintenance_window_day >= 1 && var.maintenance_window_day <= 7
    error_message = "Maintenance window day must be between 1 and 7."
  }
}

variable "maintenance_window_hour" {
  description = "The hour of day (0-23) maintenance window for the master instance maintenance"
  type        = number
  default     = 23
  validation {
    condition     = var.maintenance_window_hour >= 0 && var.maintenance_window_hour <= 23
    error_message = "Maintenance window hour must be between 0 and 23."
  }
}

variable "maintenance_window_update_track" {
  description = "The update track of maintenance window for the master instance maintenance"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["stable", "canary"], var.maintenance_window_update_track)
    error_message = "Maintenance window update track must be either stable or canary."
  }
}

# Network Configuration
variable "ipv4_enabled" {
  description = "True if the master instance should have an IPv4 address assigned"
  type        = bool
  default     = false
}

variable "private_network" {
  description = "The VPC network from which the Cloud SQL instance is accessible for private IP"
  type        = string
  default     = null
}

variable "enable_private_path_for_google_cloud_services" {
  description = "True if the master instance should have private path for Google Cloud services enabled"
  type        = bool
  default     = false
}

variable "allocated_ip_range" {
  description = "The name of the allocated ip range for the private ip CloudSQL instance"
  type        = string
  default     = null
}

variable "require_ssl" {
  description = "True if SSL connections over IP are enforced in some cases"
  type        = bool
  default     = false
}

variable "authorized_networks" {
  description = "List of mapped public networks authorized to access to the instances"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# Insights Configuration
variable "query_insights_enabled" {
  description = "True if Query Insights feature is enabled"
  type        = bool
  default     = false
}

variable "query_string_length" {
  description = "Maximum query length stored in bytes. Between 256 and 4500"
  type        = number
  default     = 1024
  validation {
    condition     = var.query_string_length >= 256 && var.query_string_length <= 4500
    error_message = "Query string length must be between 256 and 4500."
  }
}

variable "record_application_tags" {
  description = "True if Query Insights will record application tags from query when enabled"
  type        = bool
  default     = false
}

variable "record_client_address" {
  description = "True if Query Insights will record client address when enabled"
  type        = bool
  default     = false
}

variable "query_plans_per_minute" {
  description = "Number of query execution plans captured by Insights per minute for all queries combined"
  type        = number
  default     = 5
}

# Password Validation Policy
variable "enable_password_validation_policy" {
  description = "True if password validation policy is enabled"
  type        = bool
  default     = false
}

variable "password_validation_min_length" {
  description = "Minimum number of characters allowed"
  type        = number
  default     = 8
}

variable "password_validation_complexity" {
  description = "Password complexity. Possible values are COMPLEXITY_DEFAULT, COMPLEXITY_LOW, COMPLEXITY_MEDIUM, COMPLEXITY_HIGH"
  type        = string
  default     = "COMPLEXITY_DEFAULT"
  validation {
    condition = contains([
      "COMPLEXITY_DEFAULT", "COMPLEXITY_LOW", "COMPLEXITY_MEDIUM", "COMPLEXITY_HIGH"
    ], var.password_validation_complexity)
    error_message = "Password validation complexity must be a valid complexity level."
  }
}

variable "password_validation_reuse_interval" {
  description = "Number of previous passwords that cannot be reused"
  type        = number
  default     = 0
}

variable "password_validation_disallow_username_substring" {
  description = "Disallow username as a part of the password"
  type        = bool
  default     = false
}

# Root User Configuration
variable "create_root_user" {
  description = "Create root user"
  type        = bool
  default     = true
}

variable "root_user_name" {
  description = "The name of the root user"
  type        = string
  default     = "root"
}

variable "root_user_type" {
  description = "The user type. It determines the method to authenticate the user during login"
  type        = string
  default     = "BUILT_IN"
  validation {
    condition     = contains(["BUILT_IN", "CLOUD_IAM_USER", "CLOUD_IAM_SERVICE_ACCOUNT"], var.root_user_type)
    error_message = "Root user type must be BUILT_IN, CLOUD_IAM_USER, or CLOUD_IAM_SERVICE_ACCOUNT."
  }
}

variable "generate_root_password" {
  description = "Generate a random password for the root user"
  type        = bool
  default     = true
}

variable "root_user_password" {
  description = "The password for the root user. If not set, a random password will be generated"
  type        = string
  default     = null
  sensitive   = true
}

variable "root_password_length" {
  description = "The length of the random password to generate for the root user"
  type        = number
  default     = 16
}

# Additional Databases
variable "additional_databases" {
  description = "A list of databases to be created in your cluster"
  type        = list(string)
  default     = []
}

# Additional Users
variable "additional_users" {
  description = "A list of users to be created in your cluster"
  type = map(object({
    type     = string
    password = string
    password_policy = optional(object({
      allowed_failed_attempts      = optional(number)
      password_expiration_duration = optional(string)
      enable_failed_attempts_check = optional(bool)
      enable_password_verification = optional(bool)
    }))
  }))
  default   = {}
  sensitive = true
}

# Read Replicas
variable "read_replicas" {
  description = "List of read replicas to create"
  type = map(object({
    region                = string
    tier                  = string
    availability_type     = optional(string, "ZONAL")
    disk_size            = optional(number, 20)
    disk_type            = optional(string, "PD_SSD")
    disk_autoresize      = optional(bool, true)
    disk_autoresize_limit = optional(number, 0)
    user_labels          = optional(map(string), {})
    ipv4_enabled         = optional(bool, false)
    private_network      = optional(string)
    require_ssl          = optional(bool, false)
    authorized_networks = optional(list(object({
      name  = string
      value = string
    })), [])
    failover_target = optional(bool, false)
  }))
  default = {}
}

# SSL Certificates
variable "ssl_certificates" {
  description = "Map of SSL certificates to create"
  type        = set(string)
  default     = []
}

# Timeouts
variable "create_timeout" {
  description = "The timeout for creating the SQL instance"
  type        = string
  default     = "30m"
}

variable "update_timeout" {
  description = "The timeout for updating the SQL instance"
  type        = string
  default     = "30m"
}

variable "delete_timeout" {
  description = "The timeout for deleting the SQL instance"
  type        = string
  default     = "30m"
}