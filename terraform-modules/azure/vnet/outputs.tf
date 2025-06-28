output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_address_space" {
  description = "Address space of the Virtual Network"
  value       = azurerm_virtual_network.main.address_space
}

output "vnet_location" {
  description = "Location of the Virtual Network"
  value       = azurerm_virtual_network.main.location
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = { for k, v in azurerm_subnet.main : k => v.id }
}

output "subnet_names" {
  description = "Names of the subnets"
  value       = { for k, v in azurerm_subnet.main : k => v.name }
}

output "subnet_address_prefixes" {
  description = "Address prefixes of the subnets"
  value       = { for k, v in azurerm_subnet.main : k => v.address_prefixes }
}

output "network_security_group_ids" {
  description = "IDs of the Network Security Groups"
  value       = { for k, v in azurerm_network_security_group.main : k => v.id }
}

output "network_security_group_names" {
  description = "Names of the Network Security Groups"
  value       = { for k, v in azurerm_network_security_group.main : k => v.name }
}

output "route_table_ids" {
  description = "IDs of the route tables"
  value       = { for k, v in azurerm_route_table.main : k => v.id }
}

output "route_table_names" {
  description = "Names of the route tables"
  value       = { for k, v in azurerm_route_table.main : k => v.name }
}