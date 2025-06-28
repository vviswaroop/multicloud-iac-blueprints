output "custom_role_definition_ids" {
  description = "IDs of the custom role definitions"
  value       = { for k, v in azurerm_role_definition.custom : k => v.role_definition_id }
}

output "role_assignment_ids" {
  description = "IDs of the role assignments"
  value       = azurerm_role_assignment.main[*].id
}

output "application_ids" {
  description = "Application IDs"
  value       = { for k, v in azuread_application.main : k => v.application_id }
}

output "application_object_ids" {
  description = "Application object IDs"
  value       = { for k, v in azuread_application.main : k => v.object_id }
}

output "service_principal_ids" {
  description = "Service principal IDs"
  value       = { for k, v in azuread_service_principal.main : k => v.application_id }
}

output "service_principal_object_ids" {
  description = "Service principal object IDs"
  value       = { for k, v in azuread_service_principal.main : k => v.object_id }
}

output "service_principal_passwords" {
  description = "Service principal passwords"
  value       = { for k, v in azuread_service_principal_password.main : k => v.value }
  sensitive   = true
}

output "group_ids" {
  description = "Group IDs"
  value       = { for k, v in azuread_group.main : k => v.object_id }
}

output "group_names" {
  description = "Group names"
  value       = { for k, v in azuread_group.main : k => v.display_name }
}