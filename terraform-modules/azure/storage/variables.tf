variable "name" {
  description = "Name of the storage account"
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

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  description = "Storage account kind"
  type        = string
  default     = "StorageV2"
}

variable "access_tier" {
  description = "Access tier for BlobStorage and StorageV2 accounts"
  type        = string
  default     = "Hot"
}

variable "enable_https_traffic_only" {
  description = "Forces HTTPS traffic only"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS1_2"
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "containers" {
  description = "List of storage containers"
  type = list(object({
    name                  = string
    container_access_type = optional(string, "private")
  }))
  default = []
}

variable "file_shares" {
  description = "List of file shares"
  type = list(object({
    name  = string
    quota = number
  }))
  default = []
}

variable "queues" {
  description = "List of storage queues"
  type        = list(string)
  default     = []
}

variable "tables" {
  description = "List of storage tables"
  type        = list(string)
  default     = []
}

variable "network_rules" {
  description = "Network rules for the storage account"
  type = object({
    default_action             = string
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "identity" {
  description = "Identity configuration"
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null
}

variable "blob_properties" {
  description = "Blob service properties"
  type = object({
    versioning_enabled       = optional(bool, false)
    change_feed_enabled      = optional(bool, false)
    default_service_version  = optional(string, "2020-06-12")
    last_access_time_enabled = optional(bool, false)

    cors_rule = optional(list(object({
      allowed_origins    = list(string)
      allowed_methods    = list(string)
      allowed_headers    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })), [])

    delete_retention_policy = optional(object({
      days = optional(number, 7)
    }), {})

    container_delete_retention_policy = optional(object({
      days = optional(number, 7)
    }), {})
  })
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}