resource "azurerm_mssql_server" "main" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.sql_server_version
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator != null ? [var.azuread_administrator] : []
    content {
      login_username = azuread_administrator.value.login_username
      object_id      = azuread_administrator.value.object_id
      tenant_id      = azuread_administrator.value.tenant_id
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  connection_policy                    = var.connection_policy
  transparent_data_encryption_key_vault_key_id = var.transparent_data_encryption_key_vault_key_id

  tags = var.tags
}

resource "azurerm_mssql_database" "databases" {
  for_each = var.databases

  name           = each.key
  server_id      = azurerm_mssql_server.main.id
  collation      = each.value.collation
  license_type   = each.value.license_type
  max_size_gb    = each.value.max_size_gb
  read_scale     = each.value.read_scale
  sku_name       = each.value.sku_name
  zone_redundant = each.value.zone_redundant
  storage_account_type = each.value.storage_account_type

  dynamic "threat_detection_policy" {
    for_each = each.value.threat_detection_policy != null ? [each.value.threat_detection_policy] : []
    content {
      state                      = threat_detection_policy.value.state
      disabled_alerts            = threat_detection_policy.value.disabled_alerts
      email_account_admins       = threat_detection_policy.value.email_account_admins
      email_addresses            = threat_detection_policy.value.email_addresses
      retention_days             = threat_detection_policy.value.retention_days
      storage_account_access_key = threat_detection_policy.value.storage_account_access_key
      storage_endpoint           = threat_detection_policy.value.storage_endpoint
    }
  }

  dynamic "long_term_retention_policy" {
    for_each = each.value.long_term_retention_policy != null ? [each.value.long_term_retention_policy] : []
    content {
      weekly_retention  = long_term_retention_policy.value.weekly_retention
      monthly_retention = long_term_retention_policy.value.monthly_retention
      yearly_retention  = long_term_retention_policy.value.yearly_retention
      week_of_year      = long_term_retention_policy.value.week_of_year
    }
  }

  dynamic "short_term_retention_policy" {
    for_each = each.value.short_term_retention_policy != null ? [each.value.short_term_retention_policy] : []
    content {
      retention_days                   = short_term_retention_policy.value.retention_days
      backup_interval_in_hours         = short_term_retention_policy.value.backup_interval_in_hours
    }
  }

  create_mode                       = each.value.create_mode
  creation_source_database_id       = each.value.creation_source_database_id
  restore_point_in_time             = each.value.restore_point_in_time
  recover_database_id               = each.value.recover_database_id
  restore_dropped_database_id       = each.value.restore_dropped_database_id
  read_replica_count                = each.value.read_replica_count
  sample_name                       = each.value.sample_name
  transparent_data_encryption_enabled = each.value.transparent_data_encryption_enabled

  tags = var.tags
}

resource "azurerm_mssql_firewall_rule" "firewall_rules" {
  for_each = var.firewall_rules

  name             = each.key
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

resource "azurerm_mssql_virtual_network_rule" "vnet_rules" {
  for_each = var.virtual_network_rules

  name      = each.key
  server_id = azurerm_mssql_server.main.id
  subnet_id = each.value.subnet_id
  ignore_missing_vnet_service_endpoint = each.value.ignore_missing_vnet_service_endpoint
}

resource "azurerm_private_endpoint" "sql_pe" {
  count = var.private_endpoint_config != null ? 1 : 0

  name                = var.private_endpoint_config.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_config.subnet_id

  private_service_connection {
    name                           = var.private_endpoint_config.private_service_connection_name
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_endpoint_config.private_dns_zone_group != null ? [var.private_endpoint_config.private_dns_zone_group] : []
    content {
      name                 = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }

  tags = var.tags
}

resource "azurerm_mssql_server_security_alert_policy" "security_alert_policy" {
  count = var.security_alert_policy != null ? 1 : 0

  resource_group_name        = var.resource_group_name
  server_name                = azurerm_mssql_server.main.name
  state                      = var.security_alert_policy.state
  disabled_alerts            = var.security_alert_policy.disabled_alerts
  email_account_admins       = var.security_alert_policy.email_account_admins
  email_addresses            = var.security_alert_policy.email_addresses
  retention_days             = var.security_alert_policy.retention_days
  storage_account_access_key = var.security_alert_policy.storage_account_access_key
  storage_endpoint           = var.security_alert_policy.storage_endpoint
}

resource "azurerm_mssql_server_vulnerability_assessment" "vulnerability_assessment" {
  count = var.vulnerability_assessment != null ? 1 : 0

  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.security_alert_policy[0].id
  storage_container_path          = var.vulnerability_assessment.storage_container_path
  storage_account_access_key      = var.vulnerability_assessment.storage_account_access_key

  dynamic "recurring_scans" {
    for_each = var.vulnerability_assessment.recurring_scans != null ? [var.vulnerability_assessment.recurring_scans] : []
    content {
      enabled                   = recurring_scans.value.enabled
      email_subscription_admins = recurring_scans.value.email_subscription_admins
      emails                    = recurring_scans.value.emails
    }
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "extended_auditing_policy" {
  count = var.extended_auditing_policy != null ? 1 : 0

  server_id                               = azurerm_mssql_server.main.id
  storage_endpoint                        = var.extended_auditing_policy.storage_endpoint
  storage_account_access_key              = var.extended_auditing_policy.storage_account_access_key
  storage_account_access_key_is_secondary = var.extended_auditing_policy.storage_account_access_key_is_secondary
  retention_in_days                       = var.extended_auditing_policy.retention_in_days
  log_monitoring_enabled                  = var.extended_auditing_policy.log_monitoring_enabled
}