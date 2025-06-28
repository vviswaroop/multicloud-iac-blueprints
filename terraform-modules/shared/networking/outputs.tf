# Shared Networking Module - Outputs

# VPC Information
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = var.vpc_cidr_block
}

# Subnet Information
output "calculated_subnets" {
  description = "All calculated subnet configurations"
  value       = local.calculated_subnets
}

output "all_subnets" {
  description = "All subnet configurations (calculated and manual)"
  value       = local.all_subnets
}

output "public_subnets" {
  description = "Public subnet configurations"
  value       = local.public_subnets
}

output "private_subnets" {
  description = "Private subnet configurations"
  value       = local.private_subnets
}

output "database_subnets" {
  description = "Database subnet configurations"
  value       = local.database_subnets
}

output "subnet_cidr_blocks" {
  description = "Map of subnet names to their CIDR blocks"
  value       = { for name, config in local.all_subnets : name => config.cidr_block }
}

output "subnet_availability_zones" {
  description = "Map of subnet names to their availability zones"
  value       = { for name, config in local.all_subnets : name => config.availability_zone }
}

output "subnets_by_type" {
  description = "Subnets grouped by type"
  value = {
    public   = [for name, config in local.public_subnets : name]
    private  = [for name, config in local.private_subnets : name]
    database = [for name, config in local.database_subnets : name]
  }
}

output "subnets_by_az" {
  description = "Subnets grouped by availability zone"
  value = {
    for az in distinct([for config in local.all_subnets : config.availability_zone]) :
    az => [for name, config in local.all_subnets : name if config.availability_zone == az]
  }
}

# NAT Gateway Information
output "nat_gateway_enabled" {
  description = "Whether NAT Gateway is enabled"
  value       = var.enable_nat_gateway
}

output "nat_gateway_configurations" {
  description = "NAT Gateway configurations"
  value       = local.nat_gateway_configs
}

output "single_nat_gateway" {
  description = "Whether using a single NAT Gateway"
  value       = var.single_nat_gateway
}

output "nat_gateway_count" {
  description = "Number of NAT Gateways"
  value       = length(local.nat_gateway_configs)
}

# Route Table Information
output "private_route_table_associations" {
  description = "Private subnet route table associations"
  value       = local.private_route_table_associations
}

# Security Group Information
output "security_groups_config" {
  description = "Processed security group configurations"
  value       = local.processed_sg_rules
}

output "security_group_names" {
  description = "List of security group names"
  value       = keys(local.processed_sg_rules)
}

output "security_groups_by_type" {
  description = "Security groups categorized by common patterns"
  value = {
    web_tier = [
      for name, config in local.processed_sg_rules : name
      if length([for rule in config.ingress_rules : rule if rule.from_port == 80 || rule.from_port == 443]) > 0
    ]
    database_tier = [
      for name, config in local.processed_sg_rules : name
      if length([for rule in config.ingress_rules : rule if rule.from_port == 3306 || rule.from_port == 5432 || rule.from_port == 1433]) > 0
    ]
    management = [
      for name, config in local.processed_sg_rules : name
      if length([for rule in config.ingress_rules : rule if rule.from_port == 22 || rule.from_port == 3389]) > 0
    ]
  }
}

# Network ACL Information
output "network_acls_config" {
  description = "Processed network ACL configurations"
  value       = local.processed_nacl_rules
}

output "network_acl_names" {
  description = "List of network ACL names"
  value       = keys(local.processed_nacl_rules)
}

# VPC Peering Information
output "vpc_peering_enabled" {
  description = "Whether VPC peering is configured"
  value       = length(var.vpc_peering_connections) > 0
}

output "vpc_peering_configurations" {
  description = "VPC peering configurations"
  value       = local.vpc_peering_configs
}

output "vpc_peering_count" {
  description = "Number of VPC peering connections"
  value       = length(var.vpc_peering_connections)
}

# Transit Gateway Information
output "transit_gateway_enabled" {
  description = "Whether Transit Gateway is enabled"
  value       = var.enable_transit_gateway
}

output "transit_gateway_configurations" {
  description = "Transit Gateway configurations"
  value       = local.transit_gateway_configs
}

# VPN Gateway Information
output "vpn_gateway_enabled" {
  description = "Whether VPN Gateway is enabled"
  value       = var.enable_vpn_gateway
}

output "vpn_gateway_configurations" {
  description = "VPN Gateway configurations"
  value       = local.vpn_gateway_configs
}

# Load Balancer Information
output "load_balancers_config" {
  description = "Load balancer configurations"
  value       = var.load_balancers
}

output "load_balancers_by_type" {
  description = "Load balancers grouped by type"
  value = {
    for lb_type in distinct([for config in var.load_balancers : config.type]) :
    lb_type => [for name, config in var.load_balancers : name if config.type == lb_type]
  }
}

# DNS Configuration
output "dns_configuration" {
  description = "DNS configuration"
  value       = var.dns_config
}

# VPC Endpoints Information
output "vpc_endpoints_config" {
  description = "VPC endpoints configuration"
  value       = var.vpc_endpoints
}

output "vpc_endpoints_by_type" {
  description = "VPC endpoints grouped by type"
  value = {
    gateway   = [for name, config in var.vpc_endpoints : name if config.vpc_endpoint_type == "Gateway"]
    interface = [for name, config in var.vpc_endpoints : name if config.vpc_endpoint_type == "Interface"]
  }
}

# Network Architecture Information
output "network_architecture" {
  description = "Network architecture summary"
  value = {
    segmentation_strategy = var.network_segmentation_strategy
    cloud_provider       = var.cloud_provider
    region               = var.region
    total_subnets        = length(local.all_subnets)
    public_subnets_count = length(local.public_subnets)
    private_subnets_count = length(local.private_subnets)
    database_subnets_count = length(local.database_subnets)
    security_groups_count = length(local.processed_sg_rules)
    network_acls_count   = length(local.processed_nacl_rules)
    nat_gateways_count   = length(local.nat_gateway_configs)
    load_balancers_count = length(var.load_balancers)
    vpc_endpoints_count  = length(var.vpc_endpoints)
  }
}

# Monitoring and Compliance
output "monitoring_enabled" {
  description = "Whether network monitoring is enabled"
  value       = var.enable_network_monitoring
}

output "monitoring_configuration" {
  description = "Network monitoring configuration"
  value       = var.network_monitoring_config
}

output "compliance_checks_enabled" {
  description = "Whether compliance checks are enabled"
  value       = var.enable_compliance_checks
}

output "compliance_standards" {
  description = "Configured compliance standards"
  value       = var.compliance_standards
}

# Multi-Cloud and DR Information
output "multi_cloud_enabled" {
  description = "Whether multi-cloud configuration is enabled"
  value       = var.multi_cloud_config.enable_multi_cloud
}

output "multi_cloud_configuration" {
  description = "Multi-cloud configuration"
  value       = var.multi_cloud_config
}

output "disaster_recovery_enabled" {
  description = "Whether disaster recovery is enabled"
  value       = var.disaster_recovery_config.enable_dr
}

output "disaster_recovery_configuration" {
  description = "Disaster recovery configuration"
  value       = var.disaster_recovery_config
}

# Enhanced Networking
output "enhanced_networking_config" {
  description = "Enhanced networking configuration"
  value       = var.enhanced_networking
}

# Tagging Information
output "common_tags" {
  description = "Common tags applied to resources"
  value       = local.common_tags
}

output "tagging_enforcement" {
  description = "Whether tag enforcement is enabled"
  value       = var.enforce_tagging
}

output "required_tags" {
  description = "Required tags"
  value       = var.required_tags
}

# Cost and Resource Planning
output "estimated_monthly_costs" {
  description = "Estimated monthly costs breakdown"
  value = {
    nat_gateways     = var.enable_nat_gateway ? length(local.nat_gateway_configs) * 45 : 0
    transit_gateway  = var.enable_transit_gateway ? 36 : 0
    vpn_gateway      = var.enable_vpn_gateway ? 36 : 0
    load_balancers   = length(var.load_balancers) * 16.20
    total_base_cost  = (var.enable_nat_gateway ? length(local.nat_gateway_configs) * 45 : 0) + 
                      (var.enable_transit_gateway ? 36 : 0) + 
                      (var.enable_vpn_gateway ? 36 : 0) + 
                      (length(var.load_balancers) * 16.20)
    note = "Estimates in USD, actual costs depend on data transfer and usage"
  }
}

# Network Capacity Planning
output "network_capacity_planning" {
  description = "Network capacity planning information"
  value = {
    vpc_cidr_size = pow(2, 32 - tonumber(split("/", var.vpc_cidr_block)[1]))
    total_subnet_capacity = sum([
      for config in local.all_subnets :
      pow(2, 32 - tonumber(split("/", config.cidr_block)[1]))
    ])
    available_addresses = pow(2, 32 - tonumber(split("/", var.vpc_cidr_block)[1])) - sum([
      for config in local.all_subnets :
      pow(2, 32 - tonumber(split("/", config.cidr_block)[1]))
    ])
    utilization_percentage = (sum([
      for config in local.all_subnets :
      pow(2, 32 - tonumber(split("/", config.cidr_block)[1]))
    ]) / pow(2, 32 - tonumber(split("/", var.vpc_cidr_block)[1]))) * 100
  }
}

# Validation Results
output "validation_results" {
  description = "Network validation results"
  value = {
    cidr_validation_enabled      = var.validate_cidr_blocks
    security_group_validation_enabled = var.validate_security_groups
    subnet_calculations_output   = var.output_subnet_calculations
    network_topology_generated   = var.generate_network_topology
    cost_estimation_generated    = var.generate_cost_estimation
  }
}

# Documentation Files
output "generated_files" {
  description = "List of generated documentation files"
  value = compact([
    var.output_subnet_calculations ? "subnet-calculations.json" : "",
    var.generate_network_topology ? "network-topology.md" : "",
    var.generate_cost_estimation ? "networking-cost-estimation.txt" : "",
    var.enable_network_monitoring ? "network-monitoring-config.json" : "",
    var.enable_compliance_checks ? "compliance-check-results.json" : ""
  ])
}