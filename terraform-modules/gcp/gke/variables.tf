# GCP GKE Module - Variables

# Required Variables
variable "project_id" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster (required)"
  type        = string
}

variable "location" {
  description = "The location (region or zone) to host the cluster in"
  type        = string
}

# Cluster Configuration
variable "description" {
  description = "The description of the cluster"
  type        = string
  default     = ""
}

variable "min_master_version" {
  description = "The minimum version of the master. GKE will auto-update the master to new versions, so this does not guarantee the current master version"
  type        = string
  default     = null
}

variable "remove_default_node_pool" {
  description = "Remove default node pool while setting up the cluster"
  type        = bool
  default     = true
}

variable "initial_node_count" {
  description = "The number of nodes to create in this cluster (not including the Kubernetes master)"
  type        = number
  default     = 1
}

variable "enable_autopilot" {
  description = "Enable Autopilot for this cluster"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the cluster"
  type        = bool
  default     = true
}

# Network Configuration
variable "network" {
  description = "The name or self_link of the Google Compute Engine network to which the cluster is connected"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The name or self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched"
  type        = string
  default     = null
}

variable "ip_allocation_policy" {
  description = "Configuration for cluster IP allocation"
  type = object({
    cluster_secondary_range_name  = optional(string)
    services_secondary_range_name = optional(string)
    cluster_ipv4_cidr_block       = optional(string)
    services_ipv4_cidr_block      = optional(string)
  })
  default = null
}

# Addon Configuration
variable "http_load_balancing_disabled" {
  description = "The status of the HTTP (L7) load balancing controller addon"
  type        = bool
  default     = false
}

variable "horizontal_pod_autoscaling_disabled" {
  description = "The status of the Horizontal Pod Autoscaling addon"
  type        = bool
  default     = false
}

variable "network_policy_disabled" {
  description = "Whether we should enable the network policy addon for the master"
  type        = bool
  default     = true
}

variable "dns_cache_enabled" {
  description = "The status of the NodeLocal DNSCache addon"
  type        = bool
  default     = true
}

variable "gce_pd_csi_driver_enabled" {
  description = "Whether the Google Compute Engine Persistent Disk Container Storage Interface (CSI) Driver is enabled for this cluster"
  type        = bool
  default     = true
}

variable "filestore_csi_driver_enabled" {
  description = "The status of the Filestore CSI driver addon"
  type        = bool
  default     = false
}

variable "gcs_fuse_csi_driver_enabled" {
  description = "The status of the GCS Fuse CSI driver addon"
  type        = bool
  default     = false
}

variable "gke_backup_agent_enabled" {
  description = "Whether the GKE Backup Agent is enabled for this cluster"
  type        = bool
  default     = false
}

variable "config_connector_enabled" {
  description = "Whether the Config Connector is enabled for this cluster"
  type        = bool
  default     = false
}

variable "kalm_enabled" {
  description = "Whether the Kalm addon is enabled for this cluster"
  type        = bool
  default     = false
}

variable "istio_disabled" {
  description = "The status of the Istio addon"
  type        = bool
  default     = true
}

variable "istio_auth" {
  description = "The authentication type between services in Istio"
  type        = string
  default     = "AUTH_MUTUAL_TLS"
  validation {
    condition     = contains(["AUTH_MUTUAL_TLS", "AUTH_NONE"], var.istio_auth)
    error_message = "Istio auth must be either AUTH_MUTUAL_TLS or AUTH_NONE."
  }
}

variable "cloudrun_disabled" {
  description = "The status of the Cloud Run addon"
  type        = bool
  default     = true
}

variable "cloudrun_load_balancer_type" {
  description = "The load balancer type of Cloud Run addon"
  type        = string
  default     = "LOAD_BALANCER_TYPE_EXTERNAL"
  validation {
    condition = contains([
      "LOAD_BALANCER_TYPE_EXTERNAL", "LOAD_BALANCER_TYPE_INTERNAL"
    ], var.cloudrun_load_balancer_type)
    error_message = "Cloud Run load balancer type must be either LOAD_BALANCER_TYPE_EXTERNAL or LOAD_BALANCER_TYPE_INTERNAL."
  }
}

# Network Policy
variable "network_policy_enabled" {
  description = "Enable network policy addon"
  type        = bool
  default     = false
}

variable "network_policy_provider" {
  description = "The selected network policy provider"
  type        = string
  default     = "CALICO"
  validation {
    condition     = contains(["CALICO"], var.network_policy_provider)
    error_message = "Network policy provider must be CALICO."
  }
}

# Master Authorized Networks
variable "master_authorized_networks_config" {
  description = "The configuration for master authorized networks feature"
  type = object({
    gcp_public_cidrs_access_enabled = optional(bool, false)
    cidr_blocks = list(object({
      cidr_block   = string
      display_name = string
    }))
  })
  default = null
}

# Private Cluster Configuration
variable "private_cluster_config" {
  description = "Configuration for private cluster"
  type = object({
    enable_private_nodes    = bool
    enable_private_endpoint = optional(bool, false)
    master_ipv4_cidr_block  = optional(string)
    master_global_access_config = optional(object({
      enabled = bool
    }))
  })
  default = null
}

# Workload Identity
variable "workload_identity_enabled" {
  description = "Enable Workload Identity"
  type        = bool
  default     = true
}

variable "workload_identity_bindings" {
  description = "Map of workload identity bindings"
  type = map(object({
    gsa_email = string
    namespace = string
    ksa_name  = string
  }))
  default = {}
}

# Database Encryption
variable "database_encryption" {
  description = "Application-layer Secrets Encryption settings"
  type = object({
    state    = string
    key_name = string
  })
  default = null
  validation {
    condition = var.database_encryption == null || contains([
      "ENCRYPTED", "DECRYPTED"
    ], var.database_encryption.state)
    error_message = "Database encryption state must be either ENCRYPTED or DECRYPTED."
  }
}

# Cluster Autoscaling
variable "cluster_autoscaling" {
  description = "Cluster autoscaling configuration"
  type = object({
    enabled = bool
    resource_limits = list(object({
      resource_type = string
      minimum       = number
      maximum       = number
    }))
    auto_provisioning_defaults = optional(object({
      oauth_scopes         = optional(list(string))
      service_account      = optional(string)
      disk_size            = optional(number)
      disk_type            = optional(string)
      image_type           = optional(string)
      machine_type         = optional(string)
      min_cpu_platform     = optional(string)
      boot_disk_kms_key    = optional(string)
      shielded_instance_config = optional(object({
        enable_secure_boot          = optional(bool)
        enable_integrity_monitoring = optional(bool)
      }))
      management = optional(object({
        auto_repair  = optional(bool)
        auto_upgrade = optional(bool)
      }))
      upgrade_settings = optional(object({
        max_surge       = optional(number)
        max_unavailable = optional(number)
        strategy        = optional(string)
      }))
    }))
  })
  default = null
}

# Maintenance Policy
variable "maintenance_policy" {
  description = "The maintenance policy to use for the cluster"
  type = object({
    daily_maintenance_window = optional(object({
      start_time = string
    }))
    recurring_window = optional(object({
      start_time = string
      end_time   = string
      recurrence = string
    }))
    maintenance_exclusions = optional(list(object({
      exclusion_name = string
      start_time     = string
      end_time       = string
      exclusion_options = optional(object({
        scope = string
      }))
    })), [])
  })
  default = null
}

# Logging Configuration
variable "logging_enabled_components" {
  description = "List of services to monitor"
  type        = list(string)
  default     = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  validation {
    condition = alltrue([
      for component in var.logging_enabled_components :
      contains(["SYSTEM_COMPONENTS", "WORKLOADS", "API_SERVER"], component)
    ])
    error_message = "Logging enabled components must be one of SYSTEM_COMPONENTS, WORKLOADS, or API_SERVER."
  }
}

# Monitoring Configuration
variable "monitoring_enabled_components" {
  description = "List of services to monitor"
  type        = list(string)
  default     = ["SYSTEM_COMPONENTS"]
  validation {
    condition = alltrue([
      for component in var.monitoring_enabled_components :
      contains(["SYSTEM_COMPONENTS", "WORKLOADS", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER"], component)
    ])
    error_message = "Monitoring enabled components must be valid GKE monitoring components."
  }
}

variable "managed_prometheus_enabled" {
  description = "Configuration for managed Prometheus"
  type        = bool
  default     = false
}

variable "advanced_datapath_observability_enabled" {
  description = "Whether advanced datapath observability is enabled"
  type        = bool
  default     = false
}

variable "advanced_datapath_observability_relay_enabled" {
  description = "Whether relay mode is enabled for advanced datapath observability"
  type        = bool
  default     = false
}

# Security Posture
variable "security_posture_enabled" {
  description = "Enable security posture for the cluster"
  type        = bool
  default     = false
}

variable "security_posture_mode" {
  description = "Sets the mode of the Kubernetes security posture API"
  type        = string
  default     = "BASIC"
  validation {
    condition     = contains(["DISABLED", "BASIC"], var.security_posture_mode)
    error_message = "Security posture mode must be either DISABLED or BASIC."
  }
}

variable "security_posture_vulnerability_mode" {
  description = "Sets the mode of the Kubernetes security posture API's off-cluster vulnerability scanning"
  type        = string
  default     = "VULNERABILITY_DISABLED"
  validation {
    condition = contains([
      "VULNERABILITY_DISABLED", "VULNERABILITY_BASIC", "VULNERABILITY_ENTERPRISE"
    ], var.security_posture_vulnerability_mode)
    error_message = "Security posture vulnerability mode must be a valid vulnerability mode."
  }
}

# Binary Authorization
variable "binary_authorization_enabled" {
  description = "Enable Binary Authorization for this cluster"
  type        = bool
  default     = false
}

variable "binary_authorization_evaluation_mode" {
  description = "Mode of operation for Binary Authorization policy evaluation"
  type        = string
  default     = "DISABLED"
  validation {
    condition = contains([
      "DISABLED", "PROJECT_SINGLETON_POLICY_ENFORCE"
    ], var.binary_authorization_evaluation_mode)
    error_message = "Binary authorization evaluation mode must be either DISABLED or PROJECT_SINGLETON_POLICY_ENFORCE."
  }
}

# Resource Labels
variable "resource_labels" {
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster"
  type        = map(string)
  default     = {}
}

# Node Pools
variable "node_pools" {
  description = "List of maps containing node pools"
  type = map(object({
    node_count      = optional(number, 1)
    machine_type    = optional(string, "e2-medium")
    disk_size_gb    = optional(number, 100)
    disk_type       = optional(string, "pd-standard")
    image_type      = optional(string, "COS_CONTAINERD")
    preemptible     = optional(bool, false)
    service_account = optional(string)
    oauth_scopes    = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
    labels          = optional(map(string), {})
    tags            = optional(list(string), [])
    metadata        = optional(map(string), {})

    autoscaling = optional(object({
      min_node_count       = number
      max_node_count       = number
      location_policy      = optional(string)
      total_min_node_count = optional(number)
      total_max_node_count = optional(number)
    }))

    shielded_instance_config = optional(object({
      enable_secure_boot          = optional(bool)
      enable_integrity_monitoring = optional(bool)
    }))

    advanced_machine_features = optional(object({
      threads_per_core = number
    }))

    local_ssd_config = optional(object({
      local_ssd_count = number
      interface       = string
    }))

    ephemeral_storage_local_ssd_config = optional(object({
      local_ssd_count = number
    }))

    gcfs_config = optional(object({
      enabled = bool
    }))

    guest_accelerators = optional(list(object({
      type               = string
      count              = number
      gpu_partition_size = optional(string)
      gpu_driver_installation_config = optional(object({
        gpu_driver_version = string
      }))
      gpu_sharing_config = optional(object({
        gpu_sharing_strategy       = string
        max_shared_clients_per_gpu = number
      }))
    })), [])

    workload_metadata_config = optional(object({
      mode = string
    }))

    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])

    sole_tenant_config = optional(object({
      node_affinities = list(object({
        key      = string
        operator = string
        values   = list(string)
      }))
    }))

    reservation_affinity = optional(object({
      consume_reservation_type = string
      key                      = optional(string)
      values                   = optional(list(string))
    }))

    sandbox_config = optional(object({
      sandbox_type = string
    }))

    boot_disk_kms_key = optional(string)
    node_group        = optional(string)
    resource_labels   = optional(map(string), {})

    logging_config = optional(object({
      variant = string
    }))

    kubelet_config = optional(object({
      cpu_manager_policy   = optional(string)
      cpu_cfs_quota        = optional(bool)
      cpu_cfs_quota_period = optional(string)
      pod_pids_limit       = optional(number)
    }))

    linux_node_config = optional(object({
      sysctls = map(string)
    }))

    management = optional(object({
      auto_repair  = optional(bool)
      auto_upgrade = optional(bool)
    }))

    upgrade_settings = optional(object({
      max_surge       = optional(number)
      max_unavailable = optional(number)
      strategy        = optional(string)
      blue_green_settings = optional(object({
        node_pool_soak_duration = optional(string)
        standard_rollout_policy = optional(object({
          batch_percentage    = optional(number)
          batch_node_count    = optional(number)
          batch_soak_duration = optional(string)
        }))
      }))
    }))

    network_config = optional(object({
      create_pod_range     = optional(bool)
      pod_range            = optional(string)
      pod_ipv4_cidr_block  = optional(string)
      enable_private_nodes = optional(bool)
      pod_cidr_overprovision_config = optional(object({
        disabled = bool
      }))
      network_performance_config = optional(object({
        total_egress_bandwidth_tier = string
      }))
    }))

    placement_policy = optional(object({
      type         = string
      policy_name  = optional(string)
      tpu_topology = optional(string)
    }))

    queued_provisioning = optional(object({
      enabled = bool
    }))
  }))
  default = {}
}

# Timeouts
variable "cluster_create_timeout" {
  description = "Timeout for creating the GKE cluster"
  type        = string
  default     = "45m"
}

variable "cluster_update_timeout" {
  description = "Timeout for updating the GKE cluster"
  type        = string
  default     = "45m"
}

variable "cluster_delete_timeout" {
  description = "Timeout for deleting the GKE cluster"
  type        = string
  default     = "45m"
}

variable "node_pool_create_timeout" {
  description = "Timeout for creating the GKE node pool"
  type        = string
  default     = "45m"
}

variable "node_pool_update_timeout" {
  description = "Timeout for updating the GKE node pool"
  type        = string
  default     = "45m"
}

variable "node_pool_delete_timeout" {
  description = "Timeout for deleting the GKE node pool"
  type        = string
  default     = "45m"
}