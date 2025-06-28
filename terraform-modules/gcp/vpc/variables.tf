variable "name" {
  description = "Name prefix for VPC resources"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "auto_create_subnetworks" {
  description = "Auto create subnetworks"
  type        = bool
  default     = false
}

variable "routing_mode" {
  description = "Network routing mode"
  type        = string
  default     = "REGIONAL"
}

variable "mtu" {
  description = "Maximum transmission unit"
  type        = number
  default     = 1460
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name                     = string
    ip_cidr_range           = string
    region                  = string
    private_ip_google_access = optional(bool, true)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
  default = []
}

variable "firewall_rules" {
  description = "List of firewall rules"
  type = list(object({
    name          = string
    description   = optional(string, "")
    direction     = string
    priority      = optional(number, 1000)
    ranges        = optional(list(string), [])
    source_tags   = optional(list(string), [])
    target_tags   = optional(list(string), [])
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
  default = []
}

variable "routes" {
  description = "List of routes"
  type = list(object({
    name             = string
    description      = optional(string, "")
    dest_range       = string
    next_hop_gateway = optional(string)
    next_hop_instance = optional(string)
    next_hop_ip      = optional(string)
    next_hop_vpn_tunnel = optional(string)
    priority         = optional(number, 1000)
    tags             = optional(list(string), [])
  }))
  default = []
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = false
}

variable "flow_log_sampling" {
  description = "Flow log sampling rate"
  type        = number
  default     = 0.5
}

variable "flow_log_interval" {
  description = "Flow log aggregation interval"
  type        = string
  default     = "INTERVAL_10_MIN"
}

variable "shared_vpc_host" {
  description = "Enable shared VPC host project"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}