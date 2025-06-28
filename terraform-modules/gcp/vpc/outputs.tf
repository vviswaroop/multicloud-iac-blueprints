output "network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.main.id
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.main.name
}

output "network_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.main.self_link
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = google_compute_subnetwork.main[*].id
}

output "subnet_names" {
  description = "Names of the subnets"
  value       = google_compute_subnetwork.main[*].name
}

output "subnet_self_links" {
  description = "Self links of the subnets"
  value       = google_compute_subnetwork.main[*].self_link
}

output "subnet_ip_cidr_ranges" {
  description = "IP CIDR ranges of the subnets"
  value       = google_compute_subnetwork.main[*].ip_cidr_range
}

output "subnet_regions" {
  description = "Regions of the subnets"
  value       = google_compute_subnetwork.main[*].region
}

output "firewall_rule_names" {
  description = "Names of the firewall rules"
  value       = google_compute_firewall.main[*].name
}

output "route_names" {
  description = "Names of the routes"
  value       = google_compute_route.main[*].name
}