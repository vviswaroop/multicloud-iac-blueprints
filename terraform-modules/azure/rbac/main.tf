data "azurerm_client_config" "current" {}

resource "azurerm_role_definition" "custom" {
  for_each = var.custom_roles

  name        = each.value.name
  scope       = each.value.scope
  description = each.value.description

  dynamic "permissions" {
    for_each = each.value.permissions
    content {
      actions          = permissions.value.actions
      not_actions      = permissions.value.not_actions
      data_actions     = permissions.value.data_actions
      not_data_actions = permissions.value.not_data_actions
    }
  }

  assignable_scopes = length(each.value.assignable_scopes) > 0 ? each.value.assignable_scopes : [each.value.scope]
}

resource "azurerm_role_assignment" "main" {
  count = length(var.role_assignments)

  scope                = var.role_assignments[count.index].scope
  role_definition_name = var.role_assignments[count.index].role_definition_name
  role_definition_id   = var.role_assignments[count.index].role_definition_id
  principal_id         = var.role_assignments[count.index].principal_id
  condition           = var.role_assignments[count.index].condition
  condition_version   = var.role_assignments[count.index].condition_version
}

resource "azuread_application" "main" {
  for_each = var.applications

  display_name = each.value.display_name
  description  = each.value.description
  owners       = each.value.owners

  dynamic "web" {
    for_each = each.value.web != null ? [each.value.web] : []
    content {
      homepage_url  = web.value.homepage_url
      logout_url    = web.value.logout_url
      redirect_uris = web.value.redirect_uris
    }
  }

  dynamic "api" {
    for_each = each.value.api != null ? [each.value.api] : []
    content {
      mapped_claims_enabled          = api.value.mapped_claims_enabled
      requested_access_token_version = api.value.requested_access_token_version
    }
  }
}

resource "azuread_service_principal" "main" {
  for_each = var.service_principals

  application_id = azuread_application.main[each.key].application_id
  description    = each.value.description
  owners         = each.value.owners
}

resource "azuread_service_principal_password" "main" {
  for_each = { for k, v in var.service_principals : k => v if v.password != null }

  service_principal_id = azuread_service_principal.main[each.key].object_id
  display_name         = each.value.password.display_name
  end_date            = each.value.password.end_date
}

resource "azuread_service_principal_certificate" "main" {
  for_each = { for k, v in var.service_principals : k => v if v.certificate != null }

  service_principal_id = azuread_service_principal.main[each.key].object_id
  display_name         = each.value.certificate.display_name
  end_date            = each.value.certificate.end_date
  key_id              = each.value.certificate.key_id
  type                = each.value.certificate.type
  usage               = each.value.certificate.usage
  value               = each.value.certificate.value
}

resource "azuread_group" "main" {
  for_each = var.groups

  display_name     = each.value.display_name
  description      = each.value.description
  security_enabled = each.value.security_enabled
  mail_enabled     = each.value.mail_enabled
  mail_nickname    = each.value.mail_nickname
  owners           = each.value.owners
  members          = each.value.members
}