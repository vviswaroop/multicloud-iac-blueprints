variable "server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "sql_server_version" {
  description = "Version of SQL Server to use"
  type        = string
  default     = "12.0"
}

variable "administrator_login" {
  description = "Administrator login username"
  type        = string
}

variable "administrator_login_password" {
  description = "Administrator login password"
  type        = string
  sensitive   = true
}

variable "minimum_tls_version" {
  description = "Minimum TLS version for the server"
  type        = string
  default     = "1.2"
  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be 1.0, 1.1, or 1.2."
  }
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled"
  type        = bool
  default     = false
}

variable "connection_policy" {
  description = "Connection policy for the server"
  type        = string
  default     = "Default"
  validation {
    condition     = contains(["Default", "Proxy", "Redirect"], var.connection_policy)
    error_message = "Connection policy must be Default, Proxy, or Redirect."
  }
}

variable "transparent_data_encryption_key_vault_key_id" {
  description = "Key Vault key ID for transparent data encryption"
  type        = string
  default     = null
}

variable "azuread_administrator" {
  description = "Azure AD administrator configuration"
  type = object({
    login_username = string
    object_id      = string
    tenant_id      = optional(string)
  })
  default = null
}

variable "identity" {
  description = "Identity configuration for the SQL Server"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

variable "databases" {
  description = "Map of databases to create"
  type = map(object({
    collation                  = optional(string, "SQL_Latin1_General_CP1_CI_AS")
    license_type              = optional(string, "LicenseIncluded")
    max_size_gb               = optional(number, 2)
    read_scale                = optional(bool, false)
    sku_name                  = optional(string, "S0")
    zone_redundant            = optional(bool, false)
    storage_account_type      = optional(string, "Geo")
    create_mode               = optional(string, "Default")
    creation_source_database_id = optional(string)
    restore_point_in_time     = optional(string)
    recover_database_id       = optional(string)
    restore_dropped_database_id = optional(string)
    read_replica_count        = optional(number, 0)
    sample_name               = optional(string)
    transparent_data_encryption_enabled = optional(bool, true)
    
    threat_detection_policy = optional(object({
      state                      = optional(string, "Enabled")
      disabled_alerts            = optional(list(string))
      email_account_admins       = optional(bool, false)
      email_addresses            = optional(list(string))
      retention_days             = optional(number, 0)
      storage_account_access_key = optional(string)
      storage_endpoint           = optional(string)
    }))
    
    long_term_retention_policy = optional(object({
      weekly_retention  = optional(string, "PT0S")
      monthly_retention = optional(string, "PT0S")
      yearly_retention  = optional(string, "PT0S")
      week_of_year      = optional(number, 1)
    }))
    
    short_term_retention_policy = optional(object({
      retention_days           = optional(number, 35)
      backup_interval_in_hours = optional(number, 24)
    }))
  }))
  default = {}
}

variable "firewall_rules" {
  description = "Map of firewall rules"
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "virtual_network_rules" {
  description = "Map of virtual network rules"
  type = map(object({
    subnet_id                            = string
    ignore_missing_vnet_service_endpoint = optional(bool, false)
  }))
  default = {}
}

variable "private_endpoint_config" {
  description = "Private endpoint configuration"
  type = object({
    name                             = string
    subnet_id                        = string
    private_service_connection_name  = string
    private_dns_zone_group = optional(object({
      name                 = string
      private_dns_zone_ids = list(string)
    }))
  })
  default = null
}

variable "security_alert_policy" {
  description = "Security alert policy configuration"
  type = object({
    state                      = optional(string, "Enabled")
    disabled_alerts            = optional(list(string))
    email_account_admins       = optional(bool, false)
    email_addresses            = optional(list(string))
    retention_days             = optional(number, 0)
    storage_account_access_key = optional(string)
    storage_endpoint           = optional(string)
  })
  default = null
}

variable "vulnerability_assessment" {
  description = "Vulnerability assessment configuration"
  type = object({
    storage_container_path     = string
    storage_account_access_key = string
    recurring_scans = optional(object({
      enabled                   = optional(bool, true)
      email_subscription_admins = optional(bool, false)
      emails                    = optional(list(string))
    }))
  })
  default = null
}

variable "extended_auditing_policy" {
  description = "Extended auditing policy configuration"
  type = object({
    storage_endpoint                        = string
    storage_account_access_key              = string
    storage_account_access_key_is_secondary = optional(bool, false)
    retention_in_days                       = optional(number, 0)
    log_monitoring_enabled                  = optional(bool, true)
  })
  default = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}