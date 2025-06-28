resource "azurerm_virtual_network" "main" {
  name                = "${var.name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos_protection ? [1] : []
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-vnet"
    }
  )
}

resource "azurerm_subnet" "main" {
  for_each = var.subnets

  name                 = "${var.name}-${each.key}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

resource "azurerm_network_security_group" "main" {
  for_each = var.network_security_groups

  name                = "${var.name}-${each.key}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${each.key}-nsg"
    }
  )
}

resource "azurerm_route_table" "main" {
  for_each = var.route_tables

  name                = "${var.name}-${each.key}-rt"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "route" {
    for_each = each.value.routes
    content {
      name           = route.value.name
      address_prefix = route.value.address_prefix
      next_hop_type  = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${each.key}-rt"
    }
  )
}

resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = var.subnet_nsg_associations

  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = azurerm_network_security_group.main[each.value].id
}

resource "azurerm_subnet_route_table_association" "main" {
  for_each = var.subnet_route_table_associations

  subnet_id      = azurerm_subnet.main[each.key].id
  route_table_id = azurerm_route_table.main[each.value].id
}