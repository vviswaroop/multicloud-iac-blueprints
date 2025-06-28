resource "google_compute_network" "main" {
  name                    = "${var.name}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode           = var.routing_mode
  mtu                    = var.mtu
}

resource "google_compute_shared_vpc_host_project" "main" {
  count = var.shared_vpc_host ? 1 : 0

  project = var.project_id
}

resource "google_compute_subnetwork" "main" {
  count = length(var.subnets)

  name                     = "${var.name}-${var.subnets[count.index].name}"
  ip_cidr_range           = var.subnets[count.index].ip_cidr_range
  region                  = var.subnets[count.index].region
  network                 = google_compute_network.main.id
  private_ip_google_access = var.subnets[count.index].private_ip_google_access

  dynamic "secondary_ip_range" {
    for_each = var.subnets[count.index].secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = var.flow_log_interval
      flow_sampling        = var.flow_log_sampling
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_firewall" "main" {
  count = length(var.firewall_rules)

  name        = "${var.name}-${var.firewall_rules[count.index].name}"
  network     = google_compute_network.main.name
  project     = var.project_id
  description = var.firewall_rules[count.index].description
  direction   = var.firewall_rules[count.index].direction
  priority    = var.firewall_rules[count.index].priority

  source_ranges = var.firewall_rules[count.index].ranges
  source_tags   = var.firewall_rules[count.index].source_tags
  target_tags   = var.firewall_rules[count.index].target_tags

  dynamic "allow" {
    for_each = var.firewall_rules[count.index].allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = var.firewall_rules[count.index].deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
}

resource "google_compute_route" "main" {
  count = length(var.routes)

  name        = "${var.name}-${var.routes[count.index].name}"
  network     = google_compute_network.main.name
  project     = var.project_id
  description = var.routes[count.index].description
  dest_range  = var.routes[count.index].dest_range
  priority    = var.routes[count.index].priority
  tags        = var.routes[count.index].tags

  next_hop_gateway     = var.routes[count.index].next_hop_gateway
  next_hop_instance    = var.routes[count.index].next_hop_instance
  next_hop_ip          = var.routes[count.index].next_hop_ip
  next_hop_vpn_tunnel  = var.routes[count.index].next_hop_vpn_tunnel
}