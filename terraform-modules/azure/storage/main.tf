resource "azurerm_storage_account" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  account_kind                      = var.account_kind
  access_tier                       = var.access_tier
  enable_https_traffic_only         = var.enable_https_traffic_only
  min_tls_version                   = var.min_tls_version
  public_network_access_enabled     = var.public_network_access_enabled

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  dynamic "blob_properties" {
    for_each = var.blob_properties != null ? [var.blob_properties] : []
    content {
      versioning_enabled       = blob_properties.value.versioning_enabled
      change_feed_enabled      = blob_properties.value.change_feed_enabled
      default_service_version  = blob_properties.value.default_service_version
      last_access_time_enabled = blob_properties.value.last_access_time_enabled

      dynamic "cors_rule" {
        for_each = blob_properties.value.cors_rule
        content {
          allowed_origins    = cors_rule.value.allowed_origins
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_headers    = cors_rule.value.allowed_headers
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "delete_retention_policy" {
        for_each = blob_properties.value.delete_retention_policy != null ? [blob_properties.value.delete_retention_policy] : []
        content {
          days = delete_retention_policy.value.days
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = blob_properties.value.container_delete_retention_policy != null ? [blob_properties.value.container_delete_retention_policy] : []
        content {
          days = container_delete_retention_policy.value.days
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "azurerm_storage_container" "main" {
  count = length(var.containers)

  name                  = var.containers[count.index].name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = var.containers[count.index].container_access_type
}

resource "azurerm_storage_share" "main" {
  count = length(var.file_shares)

  name                 = var.file_shares[count.index].name
  storage_account_name = azurerm_storage_account.main.name
  quota                = var.file_shares[count.index].quota
}

resource "azurerm_storage_queue" "main" {
  count = length(var.queues)

  name                 = var.queues[count.index]
  storage_account_name = azurerm_storage_account.main.name
}

resource "azurerm_storage_table" "main" {
  count = length(var.tables)

  name                 = var.tables[count.index]
  storage_account_name = azurerm_storage_account.main.name
}