resource "azurerm_public_ip" "main" {
  count = var.create_public_ip ? 1 : 0

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                = var.public_ip_sku

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-pip"
    }
  )
}

resource "azurerm_network_interface" "main" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  enable_accelerated_networking = var.accelerated_networking
  enable_ip_forwarding         = var.ip_forwarding

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address           = var.private_ip_address_allocation == "Static" ? var.private_ip_address : null
    public_ip_address_id         = var.create_public_ip ? azurerm_public_ip.main[0].id : null
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nic"
    }
  )
}

resource "azurerm_network_interface_security_group_association" "main" {
  count = var.network_security_group_id != "" ? 1 : 0

  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_managed_disk" "data" {
  count = length(var.data_disks)

  name                 = "${var.name}-${var.data_disks[count.index].name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_disks[count.index].storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disks[count.index].disk_size_gb

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${var.data_disks[count.index].name}"
    }
  )
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  disable_password_authentication = var.disable_password_authentication
  admin_password                  = var.disable_password_authentication ? null : var.admin_password

  availability_set_id           = var.availability_set_id != "" ? var.availability_set_id : null
  proximity_placement_group_id  = var.proximity_placement_group_id != "" ? var.proximity_placement_group_id : null
  zone                         = var.zone != "" ? var.zone : null

  custom_data = var.custom_data != "" ? base64encode(var.custom_data) : null
  user_data   = var.user_data != "" ? base64encode(var.user_data) : null

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
    disk_size_gb         = var.os_disk.disk_size_gb
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id == "" ? [var.source_image_reference] : []
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  source_image_id = var.source_image_id != "" ? var.source_image_id : null

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication && var.ssh_public_key != "" ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.ssh_public_key
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics != null ? [var.boot_diagnostics] : []
    content {
      storage_account_uri = boot_diagnostics.value.storage_account_uri
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  count = length(var.data_disks)

  managed_disk_id    = azurerm_managed_disk.data[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  lun                = var.data_disks[count.index].lun
  caching            = var.data_disks[count.index].caching
}

resource "azurerm_virtual_machine_extension" "main" {
  for_each = var.extensions

  name                       = each.key
  virtual_machine_id         = azurerm_linux_virtual_machine.main.id
  publisher                  = each.value.publisher
  type                       = each.value.type
  type_handler_version       = each.value.type_handler_version
  auto_upgrade_minor_version = each.value.auto_upgrade_minor_version

  settings          = each.value.settings
  protected_settings = each.value.protected_settings

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${each.key}"
    }
  )
}

resource "azurerm_backup_protected_vm" "main" {
  count = var.enable_backup && var.backup_policy_id != "" ? 1 : 0

  resource_group_name = var.resource_group_name
  recovery_vault_name = split("/", var.backup_policy_id)[8]
  source_vm_id        = azurerm_linux_virtual_machine.main.id
  backup_policy_id    = var.backup_policy_id
}