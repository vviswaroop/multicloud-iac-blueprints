variable "name" {
  description = "Name prefix for VM resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Administrator username"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Administrator password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "disable_password_authentication" {
  description = "Disable password authentication"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "SSH public key for authentication"
  type        = string
  default     = ""
}

variable "source_image_reference" {
  description = "Source image reference"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

variable "source_image_id" {
  description = "Source image ID (custom image)"
  type        = string
  default     = ""
}

variable "os_disk" {
  description = "OS disk configuration"
  type = object({
    caching              = optional(string, "ReadWrite")
    storage_account_type = optional(string, "Premium_LRS")
    disk_size_gb         = optional(number)
  })
  default = {}
}

variable "data_disks" {
  description = "Data disk configurations"
  type = list(object({
    name                 = string
    caching              = optional(string, "ReadWrite")
    storage_account_type = optional(string, "Premium_LRS")
    disk_size_gb         = number
    lun                  = number
  }))
  default = []
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "network_security_group_id" {
  description = "ID of the network security group"
  type        = string
  default     = ""
}

variable "create_public_ip" {
  description = "Create a public IP address"
  type        = bool
  default     = false
}

variable "public_ip_sku" {
  description = "SKU for the public IP"
  type        = string
  default     = "Standard"
}

variable "public_ip_allocation_method" {
  description = "Allocation method for the public IP"
  type        = string
  default     = "Static"
}

variable "accelerated_networking" {
  description = "Enable accelerated networking"
  type        = bool
  default     = false
}

variable "ip_forwarding" {
  description = "Enable IP forwarding"
  type        = bool
  default     = false
}

variable "private_ip_address_allocation" {
  description = "Private IP address allocation method"
  type        = string
  default     = "Dynamic"
}

variable "private_ip_address" {
  description = "Static private IP address"
  type        = string
  default     = ""
}

variable "availability_set_id" {
  description = "ID of the availability set"
  type        = string
  default     = ""
}

variable "proximity_placement_group_id" {
  description = "ID of the proximity placement group"
  type        = string
  default     = ""
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = ""
}

variable "identity" {
  description = "Identity configuration"
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null
}

variable "boot_diagnostics" {
  description = "Boot diagnostics configuration"
  type = object({
    storage_account_uri = optional(string)
  })
  default = null
}

variable "custom_data" {
  description = "Custom data script"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = ""
}

variable "extensions" {
  description = "VM extensions configuration"
  type = map(object({
    publisher               = string
    type                   = string
    type_handler_version   = string
    auto_upgrade_minor_version = optional(bool, true)
    settings               = optional(string, "{}")
    protected_settings     = optional(string, "{}")
  }))
  default = {}
}

variable "enable_backup" {
  description = "Enable Azure Backup"
  type        = bool
  default     = false
}

variable "backup_policy_id" {
  description = "ID of the backup policy"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}