# GCP GKE Module - Main Configuration

# Enable required APIs
resource "google_project_service" "container_api" {
  project = var.project_id
  service = "container.googleapis.com"

  disable_dependent_services = false
}

resource "google_project_service" "compute_api" {
  project = var.project_id
  service = "compute.googleapis.com"

  disable_dependent_services = false
}

# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.location
  project  = var.project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = var.remove_default_node_pool
  initial_node_count       = var.initial_node_count

  # Cluster-level configurations
  min_master_version = var.min_master_version
  description        = var.description

  # Network configuration
  network         = var.network
  subnetwork      = var.subnetwork
  enable_autopilot = var.enable_autopilot

  # Cluster addons
  addons_config {
    http_load_balancing {
      disabled = var.http_load_balancing_disabled
    }

    horizontal_pod_autoscaling {
      disabled = var.horizontal_pod_autoscaling_disabled
    }

    network_policy_config {
      disabled = var.network_policy_disabled
    }

    dns_cache_config {
      enabled = var.dns_cache_enabled
    }

    gce_persistent_disk_csi_driver_config {
      enabled = var.gce_pd_csi_driver_enabled
    }

    gcp_filestore_csi_driver_config {
      enabled = var.filestore_csi_driver_enabled
    }

    gcs_fuse_csi_driver_config {
      enabled = var.gcs_fuse_csi_driver_enabled
    }

    gke_backup_agent_config {
      enabled = var.gke_backup_agent_enabled
    }

    config_connector_config {
      enabled = var.config_connector_enabled
    }

    kalm_config {
      enabled = var.kalm_enabled
    }

    istio_config {
      disabled = var.istio_disabled
      auth     = var.istio_auth
    }

    cloudrun_config {
      disabled           = var.cloudrun_disabled
      load_balancer_type = var.cloudrun_load_balancer_type
    }
  }

  # Networking policy
  dynamic "network_policy" {
    for_each = var.network_policy_enabled ? [1] : []
    content {
      enabled  = true
      provider = var.network_policy_provider
    }
  }

  # IP allocation policy
  dynamic "ip_allocation_policy" {
    for_each = var.ip_allocation_policy != null ? [var.ip_allocation_policy] : []
    content {
      cluster_secondary_range_name  = ip_allocation_policy.value.cluster_secondary_range_name
      services_secondary_range_name = ip_allocation_policy.value.services_secondary_range_name
      cluster_ipv4_cidr_block       = ip_allocation_policy.value.cluster_ipv4_cidr_block
      services_ipv4_cidr_block      = ip_allocation_policy.value.services_ipv4_cidr_block
    }
  }

  # Master authorized networks
  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config != null ? [var.master_authorized_networks_config] : []
    content {
      gcp_public_cidrs_access_enabled = master_authorized_networks_config.value.gcp_public_cidrs_access_enabled
      
      dynamic "cidr_blocks" {
        for_each = master_authorized_networks_config.value.cidr_blocks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  # Private cluster configuration
  dynamic "private_cluster_config" {
    for_each = var.private_cluster_config != null ? [var.private_cluster_config] : []
    content {
      enable_private_nodes    = private_cluster_config.value.enable_private_nodes
      enable_private_endpoint = private_cluster_config.value.enable_private_endpoint
      master_ipv4_cidr_block  = private_cluster_config.value.master_ipv4_cidr_block

      dynamic "master_global_access_config" {
        for_each = private_cluster_config.value.master_global_access_config != null ? [private_cluster_config.value.master_global_access_config] : []
        content {
          enabled = master_global_access_config.value.enabled
        }
      }
    }
  }

  # Workload Identity
  dynamic "workload_identity_config" {
    for_each = var.workload_identity_enabled ? [1] : []
    content {
      workload_pool = "${var.project_id}.svc.id.goog"
    }
  }

  # Database encryption
  dynamic "database_encryption" {
    for_each = var.database_encryption != null ? [var.database_encryption] : []
    content {
      state    = database_encryption.value.state
      key_name = database_encryption.value.key_name
    }
  }

  # Cluster autoscaling
  dynamic "cluster_autoscaling" {
    for_each = var.cluster_autoscaling != null ? [var.cluster_autoscaling] : []
    content {
      enabled = cluster_autoscaling.value.enabled
      
      dynamic "resource_limits" {
        for_each = cluster_autoscaling.value.resource_limits
        content {
          resource_type = resource_limits.value.resource_type
          minimum       = resource_limits.value.minimum
          maximum       = resource_limits.value.maximum
        }
      }

      dynamic "auto_provisioning_defaults" {
        for_each = cluster_autoscaling.value.auto_provisioning_defaults != null ? [cluster_autoscaling.value.auto_provisioning_defaults] : []
        content {
          oauth_scopes    = auto_provisioning_defaults.value.oauth_scopes
          service_account = auto_provisioning_defaults.value.service_account
          disk_size       = auto_provisioning_defaults.value.disk_size
          disk_type       = auto_provisioning_defaults.value.disk_type
          image_type      = auto_provisioning_defaults.value.image_type
          machine_type    = auto_provisioning_defaults.value.machine_type
          min_cpu_platform = auto_provisioning_defaults.value.min_cpu_platform
          boot_disk_kms_key = auto_provisioning_defaults.value.boot_disk_kms_key

          dynamic "shielded_instance_config" {
            for_each = auto_provisioning_defaults.value.shielded_instance_config != null ? [auto_provisioning_defaults.value.shielded_instance_config] : []
            content {
              enable_secure_boot          = shielded_instance_config.value.enable_secure_boot
              enable_integrity_monitoring = shielded_instance_config.value.enable_integrity_monitoring
            }
          }

          dynamic "management" {
            for_each = auto_provisioning_defaults.value.management != null ? [auto_provisioning_defaults.value.management] : []
            content {
              auto_repair  = management.value.auto_repair
              auto_upgrade = management.value.auto_upgrade
            }
          }

          dynamic "upgrade_settings" {
            for_each = auto_provisioning_defaults.value.upgrade_settings != null ? [auto_provisioning_defaults.value.upgrade_settings] : []
            content {
              max_surge       = upgrade_settings.value.max_surge
              max_unavailable = upgrade_settings.value.max_unavailable
              strategy        = upgrade_settings.value.strategy
            }
          }
        }
      }
    }
  }

  # Maintenance policy
  dynamic "maintenance_policy" {
    for_each = var.maintenance_policy != null ? [var.maintenance_policy] : []
    content {
      dynamic "daily_maintenance_window" {
        for_each = maintenance_policy.value.daily_maintenance_window != null ? [maintenance_policy.value.daily_maintenance_window] : []
        content {
          start_time = daily_maintenance_window.value.start_time
        }
      }

      dynamic "recurring_window" {
        for_each = maintenance_policy.value.recurring_window != null ? [maintenance_policy.value.recurring_window] : []
        content {
          start_time = recurring_window.value.start_time
          end_time   = recurring_window.value.end_time
          recurrence = recurring_window.value.recurrence
        }
      }

      dynamic "maintenance_exclusion" {
        for_each = maintenance_policy.value.maintenance_exclusions
        content {
          exclusion_name = maintenance_exclusion.value.exclusion_name
          start_time     = maintenance_exclusion.value.start_time
          end_time       = maintenance_exclusion.value.end_time

          dynamic "exclusion_options" {
            for_each = maintenance_exclusion.value.exclusion_options != null ? [maintenance_exclusion.value.exclusion_options] : []
            content {
              scope = exclusion_options.value.scope
            }
          }
        }
      }
    }
  }

  # Logging configuration
  logging_config {
    enable_components = var.logging_enabled_components
  }

  # Monitoring configuration
  monitoring_config {
    enable_components = var.monitoring_enabled_components

    dynamic "managed_prometheus" {
      for_each = var.managed_prometheus_enabled ? [1] : []
      content {
        enabled = true
      }
    }

    dynamic "advanced_datapath_observability_config" {
      for_each = var.advanced_datapath_observability_enabled ? [1] : []
      content {
        enable_metrics = true
        enable_relay   = var.advanced_datapath_observability_relay_enabled
      }
    }
  }

  # Security posture
  dynamic "security_posture_config" {
    for_each = var.security_posture_enabled ? [1] : []
    content {
      mode               = var.security_posture_mode
      vulnerability_mode = var.security_posture_vulnerability_mode
    }
  }

  # Binary authorization
  dynamic "binary_authorization" {
    for_each = var.binary_authorization_enabled ? [1] : []
    content {
      evaluation_mode = var.binary_authorization_evaluation_mode
    }
  }

  # Resource labels
  resource_labels = var.resource_labels

  # Deletion protection
  deletion_protection = var.deletion_protection

  # Depends on APIs being enabled
  depends_on = [
    google_project_service.container_api,
    google_project_service.compute_api,
  ]

  timeouts {
    create = var.cluster_create_timeout
    update = var.cluster_update_timeout
    delete = var.cluster_delete_timeout
  }
}

# Node Pools
resource "google_container_node_pool" "node_pools" {
  for_each = var.node_pools

  name       = each.key
  location   = google_container_cluster.primary.location
  cluster    = google_container_cluster.primary.name
  project    = var.project_id
  node_count = each.value.node_count

  # Node pool autoscaling
  dynamic "autoscaling" {
    for_each = each.value.autoscaling != null ? [each.value.autoscaling] : []
    content {
      min_node_count       = autoscaling.value.min_node_count
      max_node_count       = autoscaling.value.max_node_count
      location_policy      = autoscaling.value.location_policy
      total_min_node_count = autoscaling.value.total_min_node_count
      total_max_node_count = autoscaling.value.total_max_node_count
    }
  }

  # Node configuration
  node_config {
    preemptible  = each.value.preemptible
    machine_type = each.value.machine_type
    disk_size_gb = each.value.disk_size_gb
    disk_type    = each.value.disk_type
    image_type   = each.value.image_type
    service_account = each.value.service_account

    oauth_scopes = each.value.oauth_scopes

    labels = each.value.labels
    tags   = each.value.tags

    # Metadata
    metadata = merge(
      {
        disable-legacy-endpoints = "true"
      },
      each.value.metadata
    )

    # Shielded Instance Config
    dynamic "shielded_instance_config" {
      for_each = each.value.shielded_instance_config != null ? [each.value.shielded_instance_config] : []
      content {
        enable_secure_boot          = shielded_instance_config.value.enable_secure_boot
        enable_integrity_monitoring = shielded_instance_config.value.enable_integrity_monitoring
      }
    }

    # Advanced machine features
    dynamic "advanced_machine_features" {
      for_each = each.value.advanced_machine_features != null ? [each.value.advanced_machine_features] : []
      content {
        threads_per_core = advanced_machine_features.value.threads_per_core
      }
    }

    # Local SSD config
    dynamic "local_ssd_config" {
      for_each = each.value.local_ssd_config != null ? [each.value.local_ssd_config] : []
      content {
        local_ssd_count = local_ssd_config.value.local_ssd_count
        interface       = local_ssd_config.value.interface
      }
    }

    # Ephemeral storage local ssd config
    dynamic "ephemeral_storage_local_ssd_config" {
      for_each = each.value.ephemeral_storage_local_ssd_config != null ? [each.value.ephemeral_storage_local_ssd_config] : []
      content {
        local_ssd_count = ephemeral_storage_local_ssd_config.value.local_ssd_count
      }
    }

    # GCFS config
    dynamic "gcfs_config" {
      for_each = each.value.gcfs_config != null ? [each.value.gcfs_config] : []
      content {
        enabled = gcfs_config.value.enabled
      }
    }

    # Guest accelerator
    dynamic "guest_accelerator" {
      for_each = each.value.guest_accelerators
      content {
        type               = guest_accelerator.value.type
        count              = guest_accelerator.value.count
        gpu_partition_size = guest_accelerator.value.gpu_partition_size
        
        dynamic "gpu_driver_installation_config" {
          for_each = guest_accelerator.value.gpu_driver_installation_config != null ? [guest_accelerator.value.gpu_driver_installation_config] : []
          content {
            gpu_driver_version = gpu_driver_installation_config.value.gpu_driver_version
          }
        }

        dynamic "gpu_sharing_config" {
          for_each = guest_accelerator.value.gpu_sharing_config != null ? [guest_accelerator.value.gpu_sharing_config] : []
          content {
            gpu_sharing_strategy       = gpu_sharing_config.value.gpu_sharing_strategy
            max_shared_clients_per_gpu = gpu_sharing_config.value.max_shared_clients_per_gpu
          }
        }
      }
    }

    # Workload metadata config
    dynamic "workload_metadata_config" {
      for_each = each.value.workload_metadata_config != null ? [each.value.workload_metadata_config] : []
      content {
        mode = workload_metadata_config.value.mode
      }
    }

    # Taint
    dynamic "taint" {
      for_each = each.value.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    # Sole tenant config
    dynamic "sole_tenant_config" {
      for_each = each.value.sole_tenant_config != null ? [each.value.sole_tenant_config] : []
      content {
        dynamic "node_affinity" {
          for_each = sole_tenant_config.value.node_affinities
          content {
            key      = node_affinity.value.key
            operator = node_affinity.value.operator
            values   = node_affinity.value.values
          }
        }
      }
    }

    # Reservation affinity
    dynamic "reservation_affinity" {
      for_each = each.value.reservation_affinity != null ? [each.value.reservation_affinity] : []
      content {
        consume_reservation_type = reservation_affinity.value.consume_reservation_type
        key                      = reservation_affinity.value.key
        values                   = reservation_affinity.value.values
      }
    }

    # Sandbox config
    dynamic "sandbox_config" {
      for_each = each.value.sandbox_config != null ? [each.value.sandbox_config] : []
      content {
        sandbox_type = sandbox_config.value.sandbox_type
      }
    }

    # Boot disk KMS key
    boot_disk_kms_key = each.value.boot_disk_kms_key

    # Node group
    node_group = each.value.node_group

    # Resource labels
    resource_labels = each.value.resource_labels

    # Logging config
    dynamic "logging_config" {
      for_each = each.value.logging_config != null ? [each.value.logging_config] : []
      content {
        variant = logging_config.value.variant
      }
    }

    # Kubelet config
    dynamic "kubelet_config" {
      for_each = each.value.kubelet_config != null ? [each.value.kubelet_config] : []
      content {
        cpu_manager_policy   = kubelet_config.value.cpu_manager_policy
        cpu_cfs_quota        = kubelet_config.value.cpu_cfs_quota
        cpu_cfs_quota_period = kubelet_config.value.cpu_cfs_quota_period
        pod_pids_limit       = kubelet_config.value.pod_pids_limit
      }
    }

    # Linux node config
    dynamic "linux_node_config" {
      for_each = each.value.linux_node_config != null ? [each.value.linux_node_config] : []
      content {
        sysctls = linux_node_config.value.sysctls
      }
    }
  }

  # Node pool management
  dynamic "management" {
    for_each = each.value.management != null ? [each.value.management] : []
    content {
      auto_repair  = management.value.auto_repair
      auto_upgrade = management.value.auto_upgrade
    }
  }

  # Upgrade settings
  dynamic "upgrade_settings" {
    for_each = each.value.upgrade_settings != null ? [each.value.upgrade_settings] : []
    content {
      max_surge       = upgrade_settings.value.max_surge
      max_unavailable = upgrade_settings.value.max_unavailable
      strategy        = upgrade_settings.value.strategy

      dynamic "blue_green_settings" {
        for_each = upgrade_settings.value.blue_green_settings != null ? [upgrade_settings.value.blue_green_settings] : []
        content {
          node_pool_soak_duration = blue_green_settings.value.node_pool_soak_duration

          dynamic "standard_rollout_policy" {
            for_each = blue_green_settings.value.standard_rollout_policy != null ? [blue_green_settings.value.standard_rollout_policy] : []
            content {
              batch_percentage    = standard_rollout_policy.value.batch_percentage
              batch_node_count    = standard_rollout_policy.value.batch_node_count
              batch_soak_duration = standard_rollout_policy.value.batch_soak_duration
            }
          }
        }
      }
    }
  }

  # Network config
  dynamic "network_config" {
    for_each = each.value.network_config != null ? [each.value.network_config] : []
    content {
      create_pod_range     = network_config.value.create_pod_range
      pod_range            = network_config.value.pod_range
      pod_ipv4_cidr_block  = network_config.value.pod_ipv4_cidr_block
      enable_private_nodes = network_config.value.enable_private_nodes

      dynamic "pod_cidr_overprovision_config" {
        for_each = network_config.value.pod_cidr_overprovision_config != null ? [network_config.value.pod_cidr_overprovision_config] : []
        content {
          disabled = pod_cidr_overprovision_config.value.disabled
        }
      }

      dynamic "network_performance_config" {
        for_each = network_config.value.network_performance_config != null ? [network_config.value.network_performance_config] : []
        content {
          total_egress_bandwidth_tier = network_performance_config.value.total_egress_bandwidth_tier
        }
      }
    }
  }

  # Placement policy
  dynamic "placement_policy" {
    for_each = each.value.placement_policy != null ? [each.value.placement_policy] : []
    content {
      type         = placement_policy.value.type
      policy_name  = placement_policy.value.policy_name
      tpu_topology = placement_policy.value.tpu_topology
    }
  }

  # Queued provisioning
  dynamic "queued_provisioning" {
    for_each = each.value.queued_provisioning != null ? [each.value.queued_provisioning] : []
    content {
      enabled = queued_provisioning.value.enabled
    }
  }

  timeouts {
    create = var.node_pool_create_timeout
    update = var.node_pool_update_timeout
    delete = var.node_pool_delete_timeout
  }
}

# Workload Identity bindings
resource "google_service_account_iam_member" "workload_identity_bindings" {
  for_each = var.workload_identity_bindings

  service_account_id = each.value.gsa_email
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.ksa_name}]"
}