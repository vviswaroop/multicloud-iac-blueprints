# GCP GKE Module - Outputs

# Cluster Information
output "cluster_name" {
  description = "Cluster name"
  value       = google_container_cluster.primary.name
}

output "cluster_id" {
  description = "Cluster ID"
  value       = google_container_cluster.primary.id
}

output "cluster_location" {
  description = "Cluster location (region/zone)"
  value       = google_container_cluster.primary.location
}

output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_master_version" {
  description = "The current version of the master in the cluster"
  value       = google_container_cluster.primary.master_version
}

output "cluster_ca_certificate" {
  description = "Cluster ca certificate (base64 encoded)"
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  sensitive   = true
}

output "cluster_client_certificate" {
  description = "Client certificate"
  value       = google_container_cluster.primary.master_auth.0.client_certificate
  sensitive   = true
}

output "cluster_client_key" {
  description = "Client key"
  value       = google_container_cluster.primary.master_auth.0.client_key
  sensitive   = true
}

output "cluster_master_auth" {
  description = "Cluster master auth configuration"
  value = {
    cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
    client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
    client_key            = google_container_cluster.primary.master_auth.0.client_key
  }
  sensitive = true
}

# Network Information
output "cluster_ipv4_cidr_block" {
  description = "The IP address range of the Kubernetes pods in this cluster"
  value       = google_container_cluster.primary.ip_allocation_policy.0.cluster_ipv4_cidr_block
}

output "services_ipv4_cidr_block" {
  description = "The IP address range of the Kubernetes services in this cluster"
  value       = google_container_cluster.primary.ip_allocation_policy.0.services_ipv4_cidr_block
}

output "cluster_secondary_range_name" {
  description = "The name of the secondary range to be used for the cluster CIDR block"
  value       = google_container_cluster.primary.ip_allocation_policy.0.cluster_secondary_range_name
}

output "services_secondary_range_name" {
  description = "The name of the secondary range to be used for the services CIDR block"
  value       = google_container_cluster.primary.ip_allocation_policy.0.services_secondary_range_name
}

# Node Pool Information
output "node_pools_names" {
  description = "List of node pools names"
  value       = [for np in google_container_node_pool.node_pools : np.name]
}

output "node_pools_versions" {
  description = "Node pool versions by pool name"
  value       = { for k, v in google_container_node_pool.node_pools : k => v.version }
}

output "node_pools_instance_group_urls" {
  description = "List of GCE instance group URLs which have been assigned to the cluster"
  value       = { for k, v in google_container_node_pool.node_pools : k => v.instance_group_urls }
}

output "node_pools_managed_instance_group_urls" {
  description = "List of instance group URLs which have been assigned to the cluster"
  value       = { for k, v in google_container_node_pool.node_pools : k => v.managed_instance_group_urls }
}

# Service Account Information
output "service_account_email" {
  description = "The service account to default running nodes as if not overridden in `node_pools`"
  value       = google_container_cluster.primary.node_config.0.service_account
}

output "service_account_name" {
  description = "The service account name to default running nodes as if not overridden in `node_pools`"
  value       = google_container_cluster.primary.node_config.0.service_account
}

# Security Information
output "workload_identity_config" {
  description = "Workload Identity configuration"
  value = var.workload_identity_enabled ? {
    workload_pool = google_container_cluster.primary.workload_identity_config.0.workload_pool
  } : null
}

output "tpu_ipv4_cidr_block" {
  description = "The IP address range of the Cloud TPUs in this cluster"
  value       = google_container_cluster.primary.tpu_ipv4_cidr_block
}

# Cluster Status
output "cluster_status" {
  description = "Status of the cluster"
  value       = google_container_cluster.primary.status
}

output "cluster_operation" {
  description = "Operation associated with the cluster"
  value       = google_container_cluster.primary.operation
}

# Addons
output "addons_config" {
  description = "The configuration of cluster addons"
  value = {
    http_load_balancing                = !google_container_cluster.primary.addons_config.0.http_load_balancing.0.disabled
    horizontal_pod_autoscaling         = !google_container_cluster.primary.addons_config.0.horizontal_pod_autoscaling.0.disabled
    network_policy_config              = !google_container_cluster.primary.addons_config.0.network_policy_config.0.disabled
    dns_cache_config                   = google_container_cluster.primary.addons_config.0.dns_cache_config.0.enabled
    gce_persistent_disk_csi_driver     = google_container_cluster.primary.addons_config.0.gce_persistent_disk_csi_driver_config.0.enabled
    gcp_filestore_csi_driver           = google_container_cluster.primary.addons_config.0.gcp_filestore_csi_driver_config.0.enabled
    gcs_fuse_csi_driver                = google_container_cluster.primary.addons_config.0.gcs_fuse_csi_driver_config.0.enabled
    gke_backup_agent                   = google_container_cluster.primary.addons_config.0.gke_backup_agent_config.0.enabled
    config_connector                   = google_container_cluster.primary.addons_config.0.config_connector_config.0.enabled
    kalm                               = google_container_cluster.primary.addons_config.0.kalm_config.0.enabled
    istio_disabled                     = google_container_cluster.primary.addons_config.0.istio_config.0.disabled
    cloudrun_disabled                  = google_container_cluster.primary.addons_config.0.cloudrun_config.0.disabled
  }
}

# Logging and Monitoring
output "logging_config" {
  description = "The logging configuration of the cluster"
  value = {
    enable_components = google_container_cluster.primary.logging_config.0.enable_components
  }
}

output "monitoring_config" {
  description = "The monitoring configuration of the cluster"
  value = {
    enable_components  = google_container_cluster.primary.monitoring_config.0.enable_components
    managed_prometheus = var.managed_prometheus_enabled ? google_container_cluster.primary.monitoring_config.0.managed_prometheus.0.enabled : false
    advanced_datapath_observability = var.advanced_datapath_observability_enabled ? {
      enable_metrics = google_container_cluster.primary.monitoring_config.0.advanced_datapath_observability_config.0.enable_metrics
      enable_relay   = google_container_cluster.primary.monitoring_config.0.advanced_datapath_observability_config.0.enable_relay
    } : null
  }
}

# Maintenance
output "maintenance_policy" {
  description = "The maintenance policy of the cluster"
  value = var.maintenance_policy != null ? {
    daily_maintenance_window = var.maintenance_policy.daily_maintenance_window != null ? {
      start_time = google_container_cluster.primary.maintenance_policy.0.daily_maintenance_window.0.start_time
      duration   = google_container_cluster.primary.maintenance_policy.0.daily_maintenance_window.0.duration
    } : null
    recurring_window = var.maintenance_policy.recurring_window != null ? {
      start_time = google_container_cluster.primary.maintenance_policy.0.recurring_window.0.start_time
      end_time   = google_container_cluster.primary.maintenance_policy.0.recurring_window.0.end_time
      recurrence = google_container_cluster.primary.maintenance_policy.0.recurring_window.0.recurrence
    } : null
  } : null
}

# Security and Compliance
output "security_posture_config" {
  description = "Security posture configuration"
  value = var.security_posture_enabled ? {
    mode               = google_container_cluster.primary.security_posture_config.0.mode
    vulnerability_mode = google_container_cluster.primary.security_posture_config.0.vulnerability_mode
  } : null
}

output "binary_authorization" {
  description = "Binary authorization configuration"
  value = var.binary_authorization_enabled ? {
    evaluation_mode = google_container_cluster.primary.binary_authorization.0.evaluation_mode
  } : null
}

output "database_encryption" {
  description = "Database encryption configuration"
  value = var.database_encryption != null ? {
    state    = google_container_cluster.primary.database_encryption.0.state
    key_name = google_container_cluster.primary.database_encryption.0.key_name
  } : null
}

# Network Policy
output "network_policy" {
  description = "Network policy configuration"
  value = var.network_policy_enabled ? {
    enabled  = google_container_cluster.primary.network_policy.0.enabled
    provider = google_container_cluster.primary.network_policy.0.provider
  } : null
}

# Private Cluster
output "private_cluster_config" {
  description = "Private cluster configuration"
  value = var.private_cluster_config != null ? {
    enable_private_nodes    = google_container_cluster.primary.private_cluster_config.0.enable_private_nodes
    enable_private_endpoint = google_container_cluster.primary.private_cluster_config.0.enable_private_endpoint
    master_ipv4_cidr_block  = google_container_cluster.primary.private_cluster_config.0.master_ipv4_cidr_block
    peering_name           = google_container_cluster.primary.private_cluster_config.0.peering_name
    private_endpoint       = google_container_cluster.primary.private_cluster_config.0.private_endpoint
    public_endpoint        = google_container_cluster.primary.private_cluster_config.0.public_endpoint
  } : null
}

# Master Authorized Networks
output "master_authorized_networks_config" {
  description = "Master authorized networks configuration"
  value = var.master_authorized_networks_config != null ? {
    cidr_blocks                     = google_container_cluster.primary.master_authorized_networks_config.0.cidr_blocks
    gcp_public_cidrs_access_enabled = google_container_cluster.primary.master_authorized_networks_config.0.gcp_public_cidrs_access_enabled
  } : null
}

# Project Information
output "project_id" {
  description = "The project ID the cluster belongs to"
  value       = var.project_id
}

output "region" {
  description = "The region the cluster resides in"
  value       = var.location
}