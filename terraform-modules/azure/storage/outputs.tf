output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "primary_queue_endpoint" {
  description = "Primary queue endpoint"
  value       = azurerm_storage_account.main.primary_queue_endpoint
}

output "primary_table_endpoint" {
  description = "Primary table endpoint"
  value       = azurerm_storage_account.main.primary_table_endpoint
}

output "primary_file_endpoint" {
  description = "Primary file endpoint"
  value       = azurerm_storage_account.main.primary_file_endpoint
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "Secondary access key"
  value       = azurerm_storage_account.main.secondary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "container_names" {
  description = "Names of the storage containers"
  value       = azurerm_storage_container.main[*].name
}

output "file_share_names" {
  description = "Names of the file shares"
  value       = azurerm_storage_share.main[*].name
}

output "queue_names" {
  description = "Names of the storage queues"
  value       = azurerm_storage_queue.main[*].name
}

output "table_names" {
  description = "Names of the storage tables"
  value       = azurerm_storage_table.main[*].name
}