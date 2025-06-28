# Azure Example Configuration Outputs

# Resource Group
output "resource_group_name" {
  description = "Name of the main resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the main resource group"
  value       = azurerm_resource_group.main.id
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.main.location
}

# Virtual Network
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.vnet.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.vnet.subnet_ids
}

output "subnet_names" {
  description = "Map of subnet names"
  value       = module.vnet.subnet_names
}

output "network_security_group_ids" {
  description = "Map of NSG names to their IDs"
  value       = module.vnet.network_security_group_ids
}

# Storage Account
output "storage_account_name" {
  description = "Name of the main storage account"
  value       = module.storage.storage_account_name
}

output "storage_account_id" {
  description = "ID of the main storage account"
  value       = module.storage.storage_account_id
}

output "storage_primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = module.storage.primary_blob_endpoint
}

output "storage_container_names" {
  description = "Names of the storage containers"
  value       = module.storage.container_names
}

output "storage_file_share_names" {
  description = "Names of the file shares"
  value       = module.storage.file_share_names
}

# SQL Server and Database
output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = module.sql.sql_server_name
}

output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = module.sql.sql_server_id
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = module.sql.sql_server_fqdn
}

output "sql_database_names" {
  description = "Names of the SQL databases"
  value       = module.sql.database_names
}

output "sql_database_ids" {
  description = "IDs of the SQL databases"
  value       = module.sql.database_ids
}

# AKS Cluster
output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = module.aks.cluster_id
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.aks.cluster_fqdn
}

output "aks_cluster_private_fqdn" {
  description = "Private FQDN of the AKS cluster"
  value       = module.aks.cluster_private_fqdn
}

output "aks_kubelet_identity" {
  description = "Kubelet identity of the AKS cluster"
  value       = module.aks.kubelet_identity
}

output "aks_node_resource_group" {
  description = "Resource group containing AKS node resources"
  value       = module.aks.node_resource_group
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL of the AKS cluster"
  value       = module.aks.oidc_issuer_url
}

# Virtual Machines
output "web_vm_id" {
  description = "ID of the web virtual machine"
  value       = module.web_vm.vm_id
}

output "web_vm_name" {
  description = "Name of the web virtual machine"
  value       = module.web_vm.vm_name
}

output "web_vm_private_ip" {
  description = "Private IP address of the web virtual machine"
  value       = module.web_vm.vm_private_ip
}

output "app_vm_id" {
  description = "ID of the application virtual machine"
  value       = module.app_vm.vm_id
}

output "app_vm_name" {
  description = "Name of the application virtual machine"
  value       = module.app_vm.vm_name
}

output "app_vm_private_ip" {
  description = "Private IP address of the application virtual machine"
  value       = module.app_vm.vm_private_ip
}

# Application Gateway
output "application_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "application_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.app_gateway.ip_address
}

output "application_gateway_fqdn" {
  description = "FQDN of the Application Gateway"
  value       = azurerm_public_ip.app_gateway.fqdn
}

# Azure Bastion
output "bastion_host_id" {
  description = "ID of the Azure Bastion host"
  value       = azurerm_bastion_host.main.id
}

output "bastion_public_ip" {
  description = "Public IP address of the Azure Bastion"
  value       = azurerm_public_ip.bastion.ip_address
}

output "bastion_fqdn" {
  description = "FQDN of the Azure Bastion"
  value       = azurerm_public_ip.bastion.fqdn
}

# Key Vault
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

# Log Analytics Workspace
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "log_analytics_workspace_customer_id" {
  description = "Customer ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.workspace_id
}

# RBAC
output "service_principal_ids" {
  description = "Map of service principal names to their IDs"
  value       = module.rbac.service_principal_ids
}

output "service_principal_object_ids" {
  description = "Map of service principal names to their object IDs"
  value       = module.rbac.service_principal_object_ids
}

output "group_ids" {
  description = "Map of group names to their IDs"
  value       = module.rbac.group_ids
}

output "group_names" {
  description = "Map of group display names"
  value       = module.rbac.group_names
}

# Sensitive Outputs (for reference, not exposed in logs)
output "ssh_public_key" {
  description = "SSH public key for VM access"
  value       = tls_private_key.ssh.public_key_openssh
  sensitive   = true
}

output "sql_admin_username" {
  description = "SQL Server administrator username"
  value       = var.sql_admin_username
  sensitive   = true
}

# Connection Information
output "connection_info" {
  description = "Important connection information"
  value = {
    application_gateway_ip = azurerm_public_ip.app_gateway.ip_address
    bastion_fqdn          = azurerm_public_ip.bastion.fqdn
    sql_server_fqdn       = module.sql.sql_server_fqdn
    aks_cluster_name      = module.aks.cluster_name
    key_vault_uri         = azurerm_key_vault.main.vault_uri
    storage_account_name  = module.storage.storage_account_name
  }
}

# Resource Endpoints
output "service_endpoints" {
  description = "Service endpoints for different tiers"
  value = {
    web_tier = {
      vm_private_ip = module.web_vm.vm_private_ip
      subnet_id     = module.vnet.subnet_ids["web"]
    }
    app_tier = {
      vm_private_ip = module.app_vm.vm_private_ip
      subnet_id     = module.vnet.subnet_ids["app"]
    }
    data_tier = {
      sql_server_fqdn = module.sql.sql_server_fqdn
      subnet_id       = module.vnet.subnet_ids["data"]
    }
    container_tier = {
      aks_cluster_fqdn = module.aks.cluster_fqdn
      subnet_id        = module.vnet.subnet_ids["aks"]
    }
  }
}

# Monitoring and Logging
output "monitoring_config" {
  description = "Monitoring and logging configuration"
  value = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
    log_analytics_customer_id  = azurerm_log_analytics_workspace.main.workspace_id
    application_insights_enabled = var.enable_monitoring
    container_insights_enabled = var.enable_container_insights
  }
}

# Security Configuration
output "security_config" {
  description = "Security configuration summary"
  value = {
    key_vault_enabled           = true
    private_endpoints_enabled   = var.enable_private_endpoints
    network_security_groups     = length(module.vnet.network_security_group_ids)
    azure_policy_enabled        = var.enable_azure_policy
    workload_identity_enabled   = var.enable_workload_identity
    sql_threat_detection_enabled = var.sql_threat_detection_enabled
  }
}

# Cost Optimization Information
output "cost_optimization" {
  description = "Cost optimization features enabled"
  value = {
    aks_autoscaling_enabled = true
    storage_lifecycle_enabled = true
    vm_scheduled_shutdown = false
    reserved_instances_recommended = true
    spot_instances_available = true
  }
}

# Backup and DR Information
output "backup_config" {
  description = "Backup and disaster recovery configuration"
  value = {
    vm_backup_enabled = var.enable_backup
    sql_backup_enabled = true
    geo_redundant_storage = var.storage_replication_type == "GRS" || var.storage_replication_type == "RAGRS"
    backup_retention_days = var.backup_retention_days
    sql_geo_backup_enabled = true
  }
}