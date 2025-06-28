output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_private_ip" {
  description = "Private IP address of the virtual machine"
  value       = azurerm_network_interface.main.private_ip_address
}

output "vm_public_ip" {
  description = "Public IP address of the virtual machine"
  value       = var.create_public_ip ? azurerm_public_ip.main[0].ip_address : null
}

output "vm_fqdn" {
  description = "FQDN of the virtual machine"
  value       = var.create_public_ip ? azurerm_public_ip.main[0].fqdn : null
}

output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.main.id
}

output "network_interface_private_ip" {
  description = "Private IP address of the network interface"
  value       = azurerm_network_interface.main.private_ip_address
}

output "public_ip_id" {
  description = "ID of the public IP"
  value       = var.create_public_ip ? azurerm_public_ip.main[0].id : null
}

output "public_ip_address" {
  description = "Public IP address"
  value       = var.create_public_ip ? azurerm_public_ip.main[0].ip_address : null
}

output "data_disk_ids" {
  description = "IDs of the data disks"
  value       = azurerm_managed_disk.data[*].id
}

output "vm_identity" {
  description = "Identity block of the virtual machine"
  value       = var.identity != null ? azurerm_linux_virtual_machine.main.identity : null
}

output "vm_admin_username" {
  description = "Administrator username of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.admin_username
}

output "vm_size" {
  description = "Size of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.size
}

output "vm_zone" {
  description = "Availability zone of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.zone
}