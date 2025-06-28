# Shared Networking Module - Main Configuration
# Common networking patterns and CIDR calculations

# CIDR calculations for subnets
locals {
  # Calculate subnet CIDRs based on the main CIDR block
  calculated_subnets = var.auto_calculate_subnets ? {
    for idx, config in var.subnet_configs : config.name => {
      cidr_block        = cidrsubnet(var.vpc_cidr_block, config.newbits, config.netnum)
      availability_zone = config.availability_zone
      type             = config.type
      tags             = config.tags
    }
  } : {}

  # Merge calculated and manual subnets
  all_subnets = merge(
    local.calculated_subnets,
    var.manual_subnets
  )

  # Separate subnets by type
  public_subnets  = { for k, v in local.all_subnets : k => v if v.type == "public" }
  private_subnets = { for k, v in local.all_subnets : k => v if v.type == "private" }
  database_subnets = { for k, v in local.all_subnets : k => v if v.type == "database" }

  # NAT Gateway configurations
  nat_gateway_configs = var.enable_nat_gateway ? (
    var.single_nat_gateway ? {
      "single" = {
        subnet_name = keys(local.public_subnets)[0]
        eip_name   = "nat-gateway-eip"
      }
    } : {
      for subnet_name, subnet_config in local.public_subnets : subnet_name => {
        subnet_name = subnet_name
        eip_name   = "${subnet_name}-nat-eip"
      }
    }
  ) : {}

  # Route table associations
  private_route_table_associations = var.enable_nat_gateway ? (
    var.single_nat_gateway ? {
      for subnet_name, subnet_config in local.private_subnets : subnet_name => {
        route_table_name = "private-rt-single"
        nat_gateway_name = "single"
      }
    } : {
      for subnet_name, subnet_config in local.private_subnets : subnet_name => {
        route_table_name = "${subnet_name}-rt"
        nat_gateway_name = try(var.nat_gateway_subnet_mapping[subnet_name], keys(local.public_subnets)[0])
      }
    }
  ) : {}

  # Security group rules processing
  processed_sg_rules = {
    for sg_name, sg_config in var.security_groups : sg_name => {
      name        = sg_config.name
      description = sg_config.description
      ingress_rules = [
        for rule in sg_config.ingress_rules : {
          from_port       = rule.from_port
          to_port         = rule.to_port
          protocol        = rule.protocol
          cidr_blocks     = rule.cidr_blocks
          security_groups = rule.security_groups
          self            = rule.self
          description     = rule.description
        }
      ]
      egress_rules = [
        for rule in sg_config.egress_rules : {
          from_port       = rule.from_port
          to_port         = rule.to_port
          protocol        = rule.protocol
          cidr_blocks     = rule.cidr_blocks
          security_groups = rule.security_groups
          self            = rule.self
          description     = rule.description
        }
      ]
      tags = sg_config.tags
    }
  }

  # Network ACL rules processing
  processed_nacl_rules = {
    for nacl_name, nacl_config in var.network_acls : nacl_name => {
      name = nacl_config.name
      subnet_names = nacl_config.subnet_names
      ingress_rules = [
        for rule in nacl_config.ingress_rules : {
          rule_number = rule.rule_number
          protocol    = rule.protocol
          rule_action = rule.rule_action
          from_port   = rule.from_port
          to_port     = rule.to_port
          cidr_block  = rule.cidr_block
        }
      ]
      egress_rules = [
        for rule in nacl_config.egress_rules : {
          rule_number = rule.rule_number
          protocol    = rule.protocol
          rule_action = rule.rule_action
          from_port   = rule.from_port
          to_port     = rule.to_port
          cidr_block  = rule.cidr_block
        }
      ]
      tags = nacl_config.tags
    }
  }

  # VPC Peering configurations
  vpc_peering_configs = {
    for peer_name, peer_config in var.vpc_peering_connections : peer_name => {
      peer_vpc_id     = peer_config.peer_vpc_id
      peer_region     = peer_config.peer_region
      peer_owner_id   = peer_config.peer_owner_id
      auto_accept     = peer_config.auto_accept
      tags           = peer_config.tags
    }
  }

  # Transit Gateway configurations
  transit_gateway_configs = var.enable_transit_gateway ? {
    main = {
      amazon_side_asn                 = var.transit_gateway_config.amazon_side_asn
      auto_accept_shared_attachments  = var.transit_gateway_config.auto_accept_shared_attachments
      default_route_table_association = var.transit_gateway_config.default_route_table_association
      default_route_table_propagation = var.transit_gateway_config.default_route_table_propagation
      description                     = var.transit_gateway_config.description
      dns_support                     = var.transit_gateway_config.dns_support
      vpn_ecmp_support               = var.transit_gateway_config.vpn_ecmp_support
      tags                           = var.transit_gateway_config.tags
    }
  } : {}

  # VPN Gateway configurations
  vpn_gateway_configs = var.enable_vpn_gateway ? {
    main = {
      type            = var.vpn_gateway_config.type
      availability_zone = var.vpn_gateway_config.availability_zone
      tags            = var.vpn_gateway_config.tags
    }
  } : {}

  # Common tags
  common_tags = merge(
    var.common_tags,
    {
      "Module"      = "shared-networking"
      "ManagedBy"   = "terraform"
    }
  )
}

# Data sources for existing resources
data "aws_availability_zones" "available" {
  count = var.cloud_provider == "aws" ? 1 : 0
  state = "available"
}

data "azurerm_resource_group" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0
  name  = var.resource_group_name
}

data "google_compute_zones" "available" {
  count   = var.cloud_provider == "gcp" ? 1 : 0
  region  = var.region
  status  = "UP"
}

# Output calculated subnets for reference
resource "local_file" "subnet_calculations" {
  count = var.output_subnet_calculations ? 1 : 0
  
  content = jsonencode({
    vpc_cidr_block = var.vpc_cidr_block
    calculated_subnets = local.calculated_subnets
    all_subnets = local.all_subnets
    public_subnets = local.public_subnets
    private_subnets = local.private_subnets
    database_subnets = local.database_subnets
  })
  
  filename = "${path.root}/subnet-calculations.json"
}

# CIDR block validation
resource "null_resource" "cidr_validation" {
  count = var.validate_cidr_blocks ? 1 : 0

  triggers = {
    vpc_cidr = var.vpc_cidr_block
    subnets  = jsonencode(local.all_subnets)
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Validating CIDR blocks..."
      
      # Check if VPC CIDR is valid
      if ! echo "${var.vpc_cidr_block}" | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$'; then
        echo "Error: Invalid VPC CIDR block format: ${var.vpc_cidr_block}"
        exit 1
      fi
      
      # Check for subnet overlaps (basic validation)
      python3 -c "
import ipaddress
import json
import sys

vpc_cidr = ipaddress.IPv4Network('${var.vpc_cidr_block}')
subnets = json.loads('${jsonencode(local.all_subnets)}')

subnet_networks = []
for name, config in subnets.items():
    try:
        subnet_net = ipaddress.IPv4Network(config['cidr_block'])
        if not subnet_net.subnet_of(vpc_cidr):
            print(f'Error: Subnet {name} ({config[\"cidr_block\"]}) is not within VPC CIDR {vpc_cidr}')
            sys.exit(1)
        subnet_networks.append((name, subnet_net))
    except ValueError as e:
        print(f'Error: Invalid CIDR block for subnet {name}: {e}')
        sys.exit(1)

# Check for overlaps
for i, (name1, net1) in enumerate(subnet_networks):
    for name2, net2 in subnet_networks[i+1:]:
        if net1.overlaps(net2):
            print(f'Error: Subnets {name1} and {name2} overlap')
            sys.exit(1)

print('CIDR validation passed')
      "
    EOT
  }
}

# Network topology documentation
resource "local_file" "network_topology" {
  count = var.generate_network_topology ? 1 : 0
  
  content = templatefile("${path.module}/templates/network-topology.md.tpl", {
    vpc_cidr_block     = var.vpc_cidr_block
    all_subnets        = local.all_subnets
    public_subnets     = local.public_subnets
    private_subnets    = local.private_subnets
    database_subnets   = local.database_subnets
    security_groups    = local.processed_sg_rules
    network_acls       = local.processed_nacl_rules
    nat_gateways       = local.nat_gateway_configs
    enable_nat_gateway = var.enable_nat_gateway
    single_nat_gateway = var.single_nat_gateway
    common_tags        = local.common_tags
  })
  
  filename = "${path.root}/network-topology.md"
}

# Security group rules validation
resource "null_resource" "security_group_validation" {
  count = var.validate_security_groups ? 1 : 0

  triggers = {
    security_groups = jsonencode(local.processed_sg_rules)
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Validating security group rules..."
      
      python3 -c "
import json
import sys

security_groups = json.loads('${jsonencode(local.processed_sg_rules)}')

for sg_name, sg_config in security_groups.items():
    print(f'Validating security group: {sg_name}')
    
    # Check for overly permissive rules
    for rule in sg_config.get('ingress_rules', []):
        if '0.0.0.0/0' in rule.get('cidr_blocks', []):
            if rule.get('from_port') == 0 and rule.get('to_port') == 65535:
                print(f'Warning: Security group {sg_name} has overly permissive ingress rule (0.0.0.0/0 on all ports)')
            elif rule.get('from_port') == 22 or rule.get('to_port') == 22:
                print(f'Warning: Security group {sg_name} allows SSH access from anywhere (0.0.0.0/0:22)')
            elif rule.get('from_port') == 3389 or rule.get('to_port') == 3389:
                print(f'Warning: Security group {sg_name} allows RDP access from anywhere (0.0.0.0/0:3389)')
    
    for rule in sg_config.get('egress_rules', []):
        if '0.0.0.0/0' in rule.get('cidr_blocks', []) and rule.get('from_port') == 0 and rule.get('to_port') == 65535:
            print(f'Info: Security group {sg_name} allows all outbound traffic (common pattern)')

print('Security group validation completed')
      "
    EOT
  }
}

# Cost estimation for networking resources
resource "local_file" "cost_estimation" {
  count = var.generate_cost_estimation ? 1 : 0
  
  content = templatefile("${path.module}/templates/cost-estimation.txt.tpl", {
    enable_nat_gateway    = var.enable_nat_gateway
    nat_gateway_count     = length(local.nat_gateway_configs)
    enable_transit_gateway = var.enable_transit_gateway
    enable_vpn_gateway    = var.enable_vpn_gateway
    vpc_peering_count     = length(var.vpc_peering_connections)
    cloud_provider        = var.cloud_provider
    region                = var.region
  })
  
  filename = "${path.root}/networking-cost-estimation.txt"
}

# Network monitoring configuration
resource "local_file" "monitoring_config" {
  count = var.enable_network_monitoring ? 1 : 0
  
  content = jsonencode({
    flow_logs = {
      enabled = var.network_monitoring_config.enable_flow_logs
      retention_days = var.network_monitoring_config.flow_logs_retention_days
      s3_bucket = var.network_monitoring_config.flow_logs_s3_bucket
    }
    cloudwatch_metrics = {
      enabled = var.network_monitoring_config.enable_cloudwatch_metrics
      detailed_monitoring = var.network_monitoring_config.detailed_monitoring
    }
    alerting = {
      enabled = var.network_monitoring_config.enable_alerting
      sns_topic = var.network_monitoring_config.alerting_sns_topic
      thresholds = var.network_monitoring_config.alerting_thresholds
    }
  })
  
  filename = "${path.root}/network-monitoring-config.json"
}

# Network compliance checks
resource "null_resource" "compliance_checks" {
  count = var.enable_compliance_checks ? 1 : 0

  triggers = {
    configuration = jsonencode({
      vpc_cidr = var.vpc_cidr_block
      subnets = local.all_subnets
      security_groups = local.processed_sg_rules
      network_acls = local.processed_nacl_rules
    })
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Running network compliance checks..."
      
      python3 -c "
import json
import ipaddress

# Configuration
config = json.loads('${jsonencode({
  vpc_cidr = var.vpc_cidr_block
  subnets = local.all_subnets
  security_groups = local.processed_sg_rules
  network_acls = local.processed_nacl_rules
})}')

compliance_issues = []

# Check 1: Private subnets should not have direct internet access
private_subnets = {k: v for k, v in config['subnets'].items() if v['type'] == 'private'}
if not private_subnets:
    compliance_issues.append('No private subnets found - consider network segmentation')

# Check 2: Database subnets should be isolated
database_subnets = {k: v for k, v in config['subnets'].items() if v['type'] == 'database'}
if not database_subnets and private_subnets:
    compliance_issues.append('Consider separate database subnets for better isolation')

# Check 3: Security groups should not allow unrestricted access
for sg_name, sg_config in config['security_groups'].items():
    for rule in sg_config.get('ingress_rules', []):
        if '0.0.0.0/0' in rule.get('cidr_blocks', []):
            if rule.get('from_port') <= 22 <= rule.get('to_port') or rule.get('from_port') <= 3389 <= rule.get('to_port'):
                compliance_issues.append(f'Security group {sg_name} allows unrestricted access to management ports')

# Check 4: Network ACLs should be used for defense in depth
if not config['network_acls']:
    compliance_issues.append('Consider implementing Network ACLs for defense in depth')

# Report results
if compliance_issues:
    print('Compliance Issues Found:')
    for issue in compliance_issues:
        print(f'  - {issue}')
else:
    print('No compliance issues found')

# Save results
with open('${path.root}/compliance-check-results.json', 'w') as f:
    json.dump({
        'status': 'passed' if not compliance_issues else 'warning',
        'issues': compliance_issues,
        'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
    }, f, indent=2)
      "
    EOT
  }
}

# Resource tagging enforcement
resource "null_resource" "tagging_enforcement" {
  count = var.enforce_tagging ? 1 : 0

  triggers = {
    required_tags = jsonencode(var.required_tags)
    common_tags   = jsonencode(local.common_tags)
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Checking tag compliance..."
      
      python3 -c "
import json

required_tags = json.loads('${jsonencode(var.required_tags)}')
common_tags = json.loads('${jsonencode(local.common_tags)}')

missing_tags = []
for tag in required_tags:
    if tag not in common_tags:
        missing_tags.append(tag)

if missing_tags:
    print(f'Missing required tags: {missing_tags}')
    exit(1)
else:
    print('All required tags are present')
      "
    EOT
  }
}