# Azure Example Configuration Variables

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project" {
  description = "Project name for resource naming"
  type        = string
  default     = "enterprise-app"
  
  validation {
    condition     = length(var.project) <= 20 && can(regex("^[a-z0-9-]+$", var.project))
    error_message = "Project name must be lowercase alphanumeric with hyphens, max 20 characters."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US"
  
  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3",
      "Central US", "North Central US", "South Central US", "West Central US",
      "Canada Central", "Canada East",
      "Brazil South", "Brazil Southeast",
      "North Europe", "West Europe", "UK South", "UK West",
      "France Central", "France South", "Germany West Central", "Germany North",
      "Norway East", "Norway West", "Switzerland North", "Switzerland West",
      "Sweden Central", "Sweden South",
      "Australia East", "Australia Southeast", "Australia Central", "Australia Central 2",
      "Japan East", "Japan West", "Korea Central", "Korea South",
      "Southeast Asia", "East Asia", "India Central", "India South", "India West"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
  
  validation {
    condition     = length(var.vnet_address_space) > 0
    error_message = "At least one address space must be specified."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = "1.28.5"
}

variable "sql_admin_username" {
  description = "Administrator username for SQL Server"
  type        = string
  default     = "sqladmin"
  sensitive   = true
  
  validation {
    condition     = length(var.sql_admin_username) >= 3 && length(var.sql_admin_username) <= 128
    error_message = "SQL admin username must be between 3 and 128 characters."
  }
}

variable "admin_email" {
  description = "Administrator email for alerts and notifications"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.admin_email))
    error_message = "Admin email must be a valid email address."
  }
}

variable "authorized_ip_ranges" {
  description = "Authorized IP ranges for AKS API server access"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for cidr in var.authorized_ip_ranges : can(cidrhost(cidr, 0))
    ])
    error_message = "All authorized IP ranges must be valid CIDR blocks."
  }
}

variable "developer_user_ids" {
  description = "List of Azure AD user object IDs for developers group"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for id in var.developer_user_ids : can(regex("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$", id))
    ])
    error_message = "All developer user IDs must be valid UUIDs."
  }
}

variable "operator_user_ids" {
  description = "List of Azure AD user object IDs for operators group"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for id in var.operator_user_ids : can(regex("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$", id))
    ])
    error_message = "All operator user IDs must be valid UUIDs."
  }
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor and Log Analytics integration"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable Azure Backup for virtual machines"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
  
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 9999
    error_message = "Backup retention days must be between 7 and 9999."
  }
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for Azure services"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics workspace"
  type        = number
  default     = 30
  
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention days must be between 30 and 730."
  }
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection for the virtual network"
  type        = bool
  default     = false
}

variable "ddos_protection_plan_id" {
  description = "ID of the DDoS protection plan (required if enable_ddos_protection is true)"
  type        = string
  default     = ""
}

variable "ssl_certificate_path" {
  description = "Path to SSL certificate for Application Gateway (optional)"
  type        = string
  default     = ""
}

variable "ssl_certificate_password" {
  description = "Password for SSL certificate (optional, sensitive)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "custom_domain_name" {
  description = "Custom domain name for the application (optional)"
  type        = string
  default     = ""
  
  validation {
    condition = var.custom_domain_name == "" || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\\.[a-zA-Z]{2,}$", var.custom_domain_name))
    error_message = "Custom domain name must be a valid domain format."
  }
}

variable "network_watcher_enabled" {
  description = "Enable Network Watcher for network monitoring"
  type        = bool
  default     = true
}

variable "key_vault_firewall_bypass_azure_services" {
  description = "Allow Azure services to bypass Key Vault firewall"
  type        = bool
  default     = true
}

variable "sql_threat_detection_enabled" {
  description = "Enable threat detection for SQL Server"
  type        = bool
  default     = true
}

variable "sql_vulnerability_assessment_enabled" {
  description = "Enable vulnerability assessment for SQL Server"
  type        = bool
  default     = true
}

variable "aks_system_node_count" {
  description = "Number of system nodes in AKS cluster"
  type        = number
  default     = 3
  
  validation {
    condition     = var.aks_system_node_count >= 1 && var.aks_system_node_count <= 100
    error_message = "AKS system node count must be between 1 and 100."
  }
}

variable "aks_user_node_count" {
  description = "Number of user nodes in AKS cluster"
  type        = number
  default     = 2
  
  validation {
    condition     = var.aks_user_node_count >= 0 && var.aks_user_node_count <= 100
    error_message = "AKS user node count must be between 0 and 100."
  }
}

variable "vm_size_web" {
  description = "VM size for web tier"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_size_app" {
  description = "VM size for application tier"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be Standard or Premium."
  }
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "GRS"
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Storage replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment   = "Production"
    Project       = "Enterprise Application"
    ManagedBy     = "Terraform"
    CostCenter    = "IT"
    Owner         = "Platform Team"
    Compliance    = "Required"
    Backup        = "Required"
    Monitoring    = "Required"
  }
}

# Optional variables for advanced configurations
variable "enable_container_insights" {
  description = "Enable Container Insights for AKS monitoring"
  type        = bool
  default     = true
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy add-on for AKS"
  type        = bool
  default     = true
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity for AKS"
  type        = bool
  default     = true
}

variable "enable_oidc_issuer" {
  description = "Enable OIDC issuer for AKS"
  type        = bool
  default     = true
}

variable "application_gateway_sku" {
  description = "SKU for Application Gateway"
  type        = string
  default     = "Standard_v2"
  
  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.application_gateway_sku)
    error_message = "Application Gateway SKU must be Standard_v2 or WAF_v2."
  }
}

variable "application_gateway_capacity" {
  description = "Capacity for Application Gateway"
  type        = number
  default     = 2
  
  validation {
    condition     = var.application_gateway_capacity >= 1 && var.application_gateway_capacity <= 125
    error_message = "Application Gateway capacity must be between 1 and 125."
  }
}