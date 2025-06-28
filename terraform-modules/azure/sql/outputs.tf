output "server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_mssql_server.main.id
}

output "server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "server_identity" {
  description = "Identity of the SQL Server"
  value       = azurerm_mssql_server.main.identity
}

output "databases" {
  description = "Information about created databases"
  value = {
    for k, v in azurerm_mssql_database.databases : k => {
      id                = v.id
      name              = v.name
      server_id         = v.server_id
      collation         = v.collation
      max_size_gb       = v.max_size_gb
      sku_name          = v.sku_name
      zone_redundant    = v.zone_redundant
      storage_account_type = v.storage_account_type
    }
  }
}

output "database_ids" {
  description = "Map of database names to their IDs"
  value = {
    for k, v in azurerm_mssql_database.databases : k => v.id
  }
}

output "firewall_rules" {
  description = "Information about firewall rules"
  value = {
    for k, v in azurerm_mssql_firewall_rule.firewall_rules : k => {
      id               = v.id
      name             = v.name
      start_ip_address = v.start_ip_address
      end_ip_address   = v.end_ip_address
    }
  }
}

output "virtual_network_rules" {
  description = "Information about virtual network rules"
  value = {
    for k, v in azurerm_mssql_virtual_network_rule.vnet_rules : k => {
      id        = v.id
      name      = v.name
      subnet_id = v.subnet_id
    }
  }
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = var.private_endpoint_config != null ? azurerm_private_endpoint.sql_pe[0].id : null
}

output "private_endpoint_private_service_connection" {
  description = "Private service connection details"
  value       = var.private_endpoint_config != null ? azurerm_private_endpoint.sql_pe[0].private_service_connection : null
}

output "connection_string_template" {
  description = "Template for connection strings (replace {database} with actual database name)"
  value       = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog={database};Persist Security Info=False;User ID=${var.administrator_login};Password={password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}

output "security_alert_policy_id" {
  description = "ID of the security alert policy"
  value       = var.security_alert_policy != null ? azurerm_mssql_server_security_alert_policy.security_alert_policy[0].id : null
}

output "vulnerability_assessment_id" {
  description = "ID of the vulnerability assessment"
  value       = var.vulnerability_assessment != null ? azurerm_mssql_server_vulnerability_assessment.vulnerability_assessment[0].id : null
}

output "extended_auditing_policy_id" {
  description = "ID of the extended auditing policy"
  value       = var.extended_auditing_policy != null ? azurerm_mssql_server_extended_auditing_policy.extended_auditing_policy[0].id : null
}