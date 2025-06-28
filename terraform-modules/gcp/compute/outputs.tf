output "instance_id" {
  description = "Instance ID"
  value       = google_compute_instance.main.instance_id
}

output "instance_name" {
  description = "Instance name"
  value       = google_compute_instance.main.name
}

output "self_link" {
  description = "Instance self link"
  value       = google_compute_instance.main.self_link
}

output "internal_ip" {
  description = "Internal IP address"
  value       = google_compute_instance.main.network_interface[0].network_ip
}

output "external_ip" {
  description = "External IP address"
  value       = var.external_ip ? google_compute_instance.main.network_interface[0].access_config[0].nat_ip : null
}

output "machine_type" {
  description = "Machine type"
  value       = google_compute_instance.main.machine_type
}

output "zone" {
  description = "Instance zone"
  value       = google_compute_instance.main.zone
}