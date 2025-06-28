variable "name" {
  description = "Name prefix for VNet resources"
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

variable "address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "dns_servers" {
  description = "List of DNS servers for the VNet"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }))
  }))
  default = {
    default = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

variable "network_security_groups" {
  description = "Map of Network Security Groups to create"
  type = map(object({
    security_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string)
      destination_port_range     = optional(string)
      source_address_prefix      = optional(string)
      destination_address_prefix = optional(string)
    })), [])
  }))
  default = {}
}

variable "route_tables" {
  description = "Map of route tables to create"
  type = map(object({
    routes = optional(list(object({
      name           = string
      address_prefix = string
      next_hop_type  = string
      next_hop_in_ip_address = optional(string)
    })), [])
  }))
  default = {}
}

variable "subnet_nsg_associations" {
  description = "Map of subnet to NSG associations"
  type        = map(string)
  default     = {}
}

variable "subnet_route_table_associations" {
  description = "Map of subnet to route table associations"
  type        = map(string)
  default     = {}
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection"
  type        = bool
  default     = false
}

variable "ddos_protection_plan_id" {
  description = "ID of the DDoS protection plan"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}