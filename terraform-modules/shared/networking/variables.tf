# Shared Networking Module - Variables

# Cloud Provider Configuration
variable "cloud_provider" {
  description = "Cloud provider (aws, azure, gcp)"
  type        = string
  default     = "aws"
  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be one of: aws, azure, gcp."
  }
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name (Azure only)"
  type        = string
  default     = null
}

# VPC/Network Configuration
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR."
  }
}

variable "auto_calculate_subnets" {
  description = "Whether to automatically calculate subnet CIDR blocks"
  type        = bool
  default     = true
}

variable "subnet_configs" {
  description = "Configuration for automatic subnet calculation"
  type = list(object({
    name              = string
    newbits           = number
    netnum            = number
    availability_zone = string
    type              = string
    tags              = optional(map(string), {})
  }))
  default = []
  validation {
    condition = alltrue([
      for config in var.subnet_configs :
      contains(["public", "private", "database"], config.type)
    ])
    error_message = "Subnet type must be one of: public, private, database."
  }
}

variable "manual_subnets" {
  description = "Manually specified subnet configurations"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    type              = string
    tags              = optional(map(string), {})
  }))
  default = {}
  validation {
    condition = alltrue([
      for name, config in var.manual_subnets :
      contains(["public", "private", "database"], config.type)
    ])
    error_message = "Subnet type must be one of: public, private, database."
  }
}

# NAT Gateway Configuration
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "nat_gateway_subnet_mapping" {
  description = "Mapping of private subnets to their NAT gateway subnets"
  type        = map(string)
  default     = {}
}

# Security Groups Configuration
variable "security_groups" {
  description = "Security groups configuration"
  type = map(object({
    name        = string
    description = string
    ingress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
      self            = optional(bool, false)
      description     = optional(string, "")
    }))
    egress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
      self            = optional(bool, false)
      description     = optional(string, "")
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

# Network ACLs Configuration
variable "network_acls" {
  description = "Network ACLs configuration"
  type = map(object({
    name         = string
    subnet_names = list(string)
    ingress_rules = list(object({
      rule_number = number
      protocol    = string
      rule_action = string
      from_port   = optional(number)
      to_port     = optional(number)
      cidr_block  = string
    }))
    egress_rules = list(object({
      rule_number = number
      protocol    = string
      rule_action = string
      from_port   = optional(number)
      to_port     = optional(number)
      cidr_block  = string
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

# VPC Peering Configuration
variable "vpc_peering_connections" {
  description = "VPC peering connections configuration"
  type = map(object({
    peer_vpc_id   = string
    peer_region   = optional(string)
    peer_owner_id = optional(string)
    auto_accept   = optional(bool, true)
    tags          = optional(map(string), {})
  }))
  default = {}
}

# Transit Gateway Configuration
variable "enable_transit_gateway" {
  description = "Enable Transit Gateway"
  type        = bool
  default     = false
}

variable "transit_gateway_config" {
  description = "Transit Gateway configuration"
  type = object({
    amazon_side_asn                 = optional(number, 64512)
    auto_accept_shared_attachments  = optional(string, "enable")
    default_route_table_association = optional(string, "enable")
    default_route_table_propagation = optional(string, "enable")
    description                     = optional(string, "Managed by Terraform")
    dns_support                     = optional(string, "enable")
    vpn_ecmp_support               = optional(string, "enable")
    tags                           = optional(map(string), {})
  })
  default = {}
}

# VPN Gateway Configuration
variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

variable "vpn_gateway_config" {
  description = "VPN Gateway configuration"
  type = object({
    type              = optional(string, "ipsec.1")
    availability_zone = optional(string)
    tags              = optional(map(string), {})
  })
  default = {}
}

# Tagging Configuration
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enforce_tagging" {
  description = "Enforce required tags"
  type        = bool
  default     = false
}

variable "required_tags" {
  description = "List of required tag keys"
  type        = list(string)
  default     = []
}

# Validation and Documentation
variable "validate_cidr_blocks" {
  description = "Validate CIDR blocks for overlaps and correctness"
  type        = bool
  default     = true
}

variable "validate_security_groups" {
  description = "Validate security group rules for common issues"
  type        = bool
  default     = true
}

variable "output_subnet_calculations" {
  description = "Output subnet calculations to a file"
  type        = bool
  default     = false
}

variable "generate_network_topology" {
  description = "Generate network topology documentation"
  type        = bool
  default     = false
}

variable "generate_cost_estimation" {
  description = "Generate cost estimation for networking resources"
  type        = bool
  default     = false
}

# Monitoring Configuration
variable "enable_network_monitoring" {
  description = "Enable network monitoring configuration"
  type        = bool
  default     = false
}

variable "network_monitoring_config" {
  description = "Network monitoring configuration"
  type = object({
    enable_flow_logs                = optional(bool, true)
    flow_logs_retention_days        = optional(number, 30)
    flow_logs_s3_bucket            = optional(string)
    enable_cloudwatch_metrics       = optional(bool, true)
    detailed_monitoring             = optional(bool, false)
    enable_alerting                 = optional(bool, false)
    alerting_sns_topic             = optional(string)
    alerting_thresholds = optional(object({
      high_network_utilization = optional(number, 80)
      packet_loss_threshold    = optional(number, 1)
      latency_threshold_ms     = optional(number, 100)
    }), {})
  })
  default = {}
}

# Compliance and Security
variable "enable_compliance_checks" {
  description = "Enable compliance checks for network configuration"
  type        = bool
  default     = false
}

variable "compliance_standards" {
  description = "Compliance standards to check against"
  type        = list(string)
  default     = ["cis", "nist", "pci-dss"]
  validation {
    condition = alltrue([
      for standard in var.compliance_standards :
      contains(["cis", "nist", "pci-dss", "hipaa", "sox"], standard)
    ])
    error_message = "Compliance standard must be one of: cis, nist, pci-dss, hipaa, sox."
  }
}

# Network Segmentation
variable "network_segmentation_strategy" {
  description = "Network segmentation strategy"
  type        = string
  default     = "three-tier"
  validation {
    condition = contains([
      "three-tier", "micro-segmentation", "flat", "hub-spoke"
    ], var.network_segmentation_strategy)
    error_message = "Network segmentation strategy must be one of: three-tier, micro-segmentation, flat, hub-spoke."
  }
}

# Load Balancer Configuration
variable "load_balancers" {
  description = "Load balancer configurations"
  type = map(object({
    type               = string
    scheme             = optional(string, "internet-facing")
    subnet_names       = list(string)
    security_groups    = optional(list(string), [])
    enable_logging     = optional(bool, false)
    logging_bucket     = optional(string)
    idle_timeout       = optional(number, 60)
    deletion_protection = optional(bool, false)
    tags               = optional(map(string), {})
  }))
  default = {}
  validation {
    condition = alltrue([
      for name, config in var.load_balancers :
      contains(["application", "network", "gateway"], config.type)
    ])
    error_message = "Load balancer type must be one of: application, network, gateway."
  }
}

# DNS Configuration
variable "dns_config" {
  description = "DNS configuration"
  type = object({
    enable_private_dns     = optional(bool, false)
    private_zone_name      = optional(string)
    enable_dns_hostnames   = optional(bool, true)
    enable_dns_resolution  = optional(bool, true)
    dns_servers           = optional(list(string), [])
  })
  default = {}
}

# Service Endpoints Configuration
variable "vpc_endpoints" {
  description = "VPC endpoints configuration"
  type = map(object({
    service_name      = string
    vpc_endpoint_type = optional(string, "Gateway")
    subnet_names      = optional(list(string), [])
    security_groups   = optional(list(string), [])
    policy            = optional(string)
    private_dns_enabled = optional(bool, true)
    tags              = optional(map(string), {})
  }))
  default = {}
  validation {
    condition = alltrue([
      for name, config in var.vpc_endpoints :
      contains(["Gateway", "Interface"], config.vpc_endpoint_type)
    ])
    error_message = "VPC endpoint type must be either Gateway or Interface."
  }
}

# Bandwidth and Performance
variable "enhanced_networking" {
  description = "Enhanced networking configuration"
  type = object({
    enable_enhanced_networking = optional(bool, false)
    enable_sr_iov             = optional(bool, false)
    placement_group_strategy   = optional(string, "cluster")
  })
  default = {}
  validation {
    condition = var.enhanced_networking.placement_group_strategy == null || contains([
      "cluster", "partition", "spread"
    ], var.enhanced_networking.placement_group_strategy)
    error_message = "Placement group strategy must be one of: cluster, partition, spread."
  }
}

# Multi-Cloud Configuration
variable "multi_cloud_config" {
  description = "Multi-cloud networking configuration"
  type = object({
    enable_multi_cloud  = optional(bool, false)
    primary_cloud       = optional(string, "aws")
    secondary_clouds    = optional(list(string), [])
    cross_cloud_connectivity = optional(object({
      vpn_connections = optional(list(object({
        source_cloud = string
        target_cloud = string
        bandwidth    = optional(string, "100M")
      })), [])
    }), {})
  })
  default = {}
}

# Disaster Recovery
variable "disaster_recovery_config" {
  description = "Disaster recovery networking configuration"
  type = object({
    enable_dr               = optional(bool, false)
    dr_region              = optional(string)
    cross_region_replication = optional(bool, false)
    failover_strategy       = optional(string, "active-passive")
    rpo_minutes            = optional(number, 60)
    rto_minutes            = optional(number, 240)
  })
  default = {}
  validation {
    condition = var.disaster_recovery_config.failover_strategy == null || contains([
      "active-active", "active-passive", "pilot-light", "warm-standby"
    ], var.disaster_recovery_config.failover_strategy)
    error_message = "Failover strategy must be one of: active-active, active-passive, pilot-light, warm-standby."
  }
}