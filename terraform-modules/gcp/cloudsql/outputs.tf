# GCP CloudSQL Module - Outputs

# Instance Information
output "instance_name" {
  description = "The instance name for the master instance"
  value       = google_sql_database_instance.main.name
}

output "instance_connection_name" {
  description = "The connection name of the master instance to be used in connection strings"
  value       = google_sql_database_instance.main.connection_name
}

output "instance_self_link" {
  description = "The URI of the master instance"
  value       = google_sql_database_instance.main.self_link
}

output "instance_service_account_email_address" {
  description = "The service account email address assigned to the master instance"
  value       = google_sql_database_instance.main.service_account_email_address
}

output "instance_first_ip_address" {
  description = "The first IPv4 address of the addresses assigned for the master instance"
  value       = google_sql_database_instance.main.first_ip_address
}

output "instance_ip_address" {
  description = "The IPv4 address assigned for the master instance"
  value       = google_sql_database_instance.main.ip_address
}

output "private_ip_address" {
  description = "The first private (PRIVATE) IPv4 address assigned for the master instance"
  value       = google_sql_database_instance.main.private_ip_address
}

output "public_ip_address" {
  description = "The first public (PRIMARY) IPv4 address assigned for the master instance"
  value       = google_sql_database_instance.main.public_ip_address
}

output "instance_server_ca_cert" {
  description = "The CA certificate information used to connect to the SQL instance via SSL"
  value       = google_sql_database_instance.main.server_ca_cert
  sensitive   = true
}

# Root User Information
output "generated_root_password" {
  description = "The auto generated default user password if not input password was provided"
  value       = var.generate_root_password && var.create_root_user ? random_password.root_password[0].result : null
  sensitive   = true
}

output "root_user_name" {
  description = "The name of the root user"
  value       = var.create_root_user ? google_sql_user.root[0].name : null
}

# Database Information
output "additional_databases" {
  description = "A list of additional databases created"
  value       = [for db in google_sql_database.additional_databases : db.name]
}

output "additional_users" {
  description = "A list of additional users created"
  value       = [for user in google_sql_user.additional_users : user.name]
}

# Read Replica Information
output "read_replica_instance_names" {
  description = "The instance names for the read replica instances"
  value       = { for k, v in google_sql_database_instance.read_replica : k => v.name }
}

output "read_replica_connection_names" {
  description = "The connection names of the read replica instances to be used in connection strings"
  value       = { for k, v in google_sql_database_instance.read_replica : k => v.connection_name }
}

output "read_replica_self_links" {
  description = "The URIs of the read replica instances"
  value       = { for k, v in google_sql_database_instance.read_replica : k => v.self_link }
}

output "read_replica_ip_addresses" {
  description = "The IPv4 addresses assigned for the read replica instances"
  value       = { for k, v in google_sql_database_instance.read_replica : k => v.ip_address }
}

output "read_replica_private_ip_addresses" {
  description = "The private IPv4 addresses assigned for the read replica instances"
  value       = { for k, v in google_sql_database_instance.read_replica : k => v.private_ip_address }
}

output "read_replica_public_ip_addresses" {
  description = "The public IPv4 addresses assigned for the read replica instances"
  value       = { for k, v in google_sql_database_instance.read_replica : k => v.public_ip_address }
}

# SSL Certificate Information
output "ssl_certificates" {
  description = "SSL certificates information"
  value = {
    for cert_name, cert in google_sql_ssl_cert.client_cert : cert_name => {
      cert            = cert.cert
      cert_serial_number = cert.cert_serial_number
      common_name     = cert.common_name
      create_time     = cert.create_time
      expiration_time = cert.expiration_time
      private_key     = cert.private_key
      server_ca_cert  = cert.server_ca_cert
      sha1_fingerprint = cert.sha1_fingerprint
    }
  }
  sensitive = true
}

# Master Instance Settings
output "master_instance_sql_network_architecture" {
  description = "The network architecture of the master instance"
  value       = google_sql_database_instance.main.settings[0].sql_network_architecture
}

output "master_instance_available_maintenance_versions" {
  description = "Available maintenance versions for the master instance"
  value       = google_sql_database_instance.main.available_maintenance_versions
}

output "master_instance_maintenance_version" {
  description = "Current maintenance version of the master instance"
  value       = google_sql_database_instance.main.maintenance_version
}

# Project Information
output "project_id" {
  description = "The project ID used for the Cloud SQL instance"
  value       = var.project_id
}

output "region" {
  description = "The region where the Cloud SQL instance is hosted"
  value       = var.region
}