variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to use"
  type        = string
  default     = "1.27.7"
}

variable "node_resource_group" {
  description = "Name of the resource group for cluster nodes"
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "SKU tier for the cluster"
  type        = string
  default     = "Free"
  validation {
    condition     = contains(["Free", "Paid"], var.sku_tier)
    error_message = "SKU tier must be Free or Paid."
  }
}

variable "private_cluster_enabled" {
  description = "Enable private cluster"
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for private cluster"
  type        = string
  default     = null
}

variable "private_cluster_public_fqdn_enabled" {
  description = "Enable public FQDN for private cluster"
  type        = bool
  default     = false
}

variable "default_node_pool" {
  description = "Configuration for the default node pool"
  type = object({
    name                = string
    node_count          = optional(number, 1)
    vm_size             = optional(string, "Standard_D2_v2")
    vnet_subnet_id      = optional(string)
    availability_zones  = optional(list(string))
    enable_auto_scaling = optional(bool, false)
    min_count          = optional(number)
    max_count          = optional(number)
    max_pods           = optional(number, 110)
    os_disk_size_gb    = optional(number, 128)
    os_disk_type       = optional(string, "Managed")
    node_taints        = optional(list(string))
    node_labels        = optional(map(string))
    only_critical_addons_enabled = optional(bool, false)
    orchestrator_version = optional(string)
    proximity_placement_group_id = optional(string)
    scale_down_mode = optional(string, "Delete")
    type           = optional(string, "VirtualMachineScaleSets")
    ultra_ssd_enabled = optional(bool, false)
    
    upgrade_settings = optional(object({
      max_surge = string
    }))
    
    kubelet_config = optional(object({
      cpu_manager_policy        = optional(string)
      cpu_cfs_quota_enabled     = optional(bool)
      cpu_cfs_quota_period      = optional(string)
      image_gc_high_threshold   = optional(number)
      image_gc_low_threshold    = optional(number)
      topology_manager_policy   = optional(string)
      allowed_unsafe_sysctls    = optional(list(string))
      container_log_max_size_mb = optional(number)
      container_log_max_line    = optional(number)
      pod_max_pid               = optional(number)
    }))
    
    linux_os_config = optional(object({
      transparent_huge_page_enabled = optional(string)
      transparent_huge_page_defrag  = optional(string)
      swap_file_size_mb            = optional(number)
      sysctl_config = optional(object({
        fs_aio_max_nr                      = optional(number)
        fs_file_max                        = optional(number)
        fs_inotify_max_user_watches        = optional(number)
        fs_nr_open                         = optional(number)
        kernel_threads_max                 = optional(number)
        net_core_netdev_max_backlog        = optional(number)
        net_core_optmem_max                = optional(number)
        net_core_rmem_default              = optional(number)
        net_core_rmem_max                  = optional(number)
        net_core_somaxconn                 = optional(number)
        net_core_wmem_default              = optional(number)
        net_core_wmem_max                  = optional(number)
        net_ipv4_ip_local_port_range_min   = optional(number)
        net_ipv4_ip_local_port_range_max   = optional(number)
        net_ipv4_neigh_default_gc_thresh1  = optional(number)
        net_ipv4_neigh_default_gc_thresh2  = optional(number)
        net_ipv4_neigh_default_gc_thresh3  = optional(number)
        net_ipv4_tcp_fin_timeout          = optional(number)
        net_ipv4_tcp_keepalive_intvl       = optional(number)
        net_ipv4_tcp_keepalive_probes      = optional(number)
        net_ipv4_tcp_keepalive_time        = optional(number)
        net_ipv4_tcp_max_syn_backlog       = optional(number)
        net_ipv4_tcp_max_tw_buckets        = optional(number)
        net_ipv4_tcp_tw_reuse              = optional(bool)
        net_netfilter_nf_conntrack_buckets = optional(number)
        net_netfilter_nf_conntrack_max     = optional(number)
        vm_max_map_count                   = optional(number)
        vm_swappiness                      = optional(number)
        vm_vfs_cache_pressure              = optional(number)
      }))
    }))
  })
}

variable "additional_node_pools" {
  description = "Additional node pools for the cluster"
  type = map(object({
    vm_size              = string
    node_count           = optional(number, 1)
    availability_zones   = optional(list(string))
    enable_auto_scaling  = optional(bool, false)
    min_count           = optional(number)
    max_count           = optional(number)
    max_pods            = optional(number, 110)
    mode                = optional(string, "User")
    node_labels         = optional(map(string))
    node_taints         = optional(list(string))
    orchestrator_version = optional(string)
    os_disk_size_gb     = optional(number, 128)
    os_disk_type        = optional(string, "Managed")
    os_type             = optional(string, "Linux")
    priority            = optional(string, "Regular")
    proximity_placement_group_id = optional(string)
    spot_max_price      = optional(number)
    ultra_ssd_enabled   = optional(bool, false)
    vnet_subnet_id      = optional(string)
    zones               = optional(list(string))
    eviction_policy     = optional(string)
    scale_down_mode     = optional(string, "Delete")
    snapshot_id         = optional(string)
    
    upgrade_settings = optional(object({
      max_surge = string
    }))
    
    kubelet_config = optional(object({
      cpu_manager_policy        = optional(string)
      cpu_cfs_quota_enabled     = optional(bool)
      cpu_cfs_quota_period      = optional(string)
      image_gc_high_threshold   = optional(number)
      image_gc_low_threshold    = optional(number)
      topology_manager_policy   = optional(string)
      allowed_unsafe_sysctls    = optional(list(string))
      container_log_max_size_mb = optional(number)
      container_log_max_line    = optional(number)
      pod_max_pid               = optional(number)
    }))
    
    linux_os_config = optional(object({
      transparent_huge_page_enabled = optional(string)
      transparent_huge_page_defrag  = optional(string)
      swap_file_size_mb            = optional(number)
      sysctl_config = optional(object({
        fs_aio_max_nr                      = optional(number)
        fs_file_max                        = optional(number)
        fs_inotify_max_user_watches        = optional(number)
        fs_nr_open                         = optional(number)
        kernel_threads_max                 = optional(number)
        net_core_netdev_max_backlog        = optional(number)
        net_core_optmem_max                = optional(number)
        net_core_rmem_default              = optional(number)
        net_core_rmem_max                  = optional(number)
        net_core_somaxconn                 = optional(number)
        net_core_wmem_default              = optional(number)
        net_core_wmem_max                  = optional(number)
        net_ipv4_ip_local_port_range_min   = optional(number)
        net_ipv4_ip_local_port_range_max   = optional(number)
        net_ipv4_neigh_default_gc_thresh1  = optional(number)
        net_ipv4_neigh_default_gc_thresh2  = optional(number)
        net_ipv4_neigh_default_gc_thresh3  = optional(number)
        net_ipv4_tcp_fin_timeout          = optional(number)
        net_ipv4_tcp_keepalive_intvl       = optional(number)
        net_ipv4_tcp_keepalive_probes      = optional(number)
        net_ipv4_tcp_keepalive_time        = optional(number)
        net_ipv4_tcp_max_syn_backlog       = optional(number)
        net_ipv4_tcp_max_tw_buckets        = optional(number)
        net_ipv4_tcp_tw_reuse              = optional(bool)
        net_netfilter_nf_conntrack_buckets = optional(number)
        net_netfilter_nf_conntrack_max     = optional(number)
        vm_max_map_count                   = optional(number)
        vm_swappiness                      = optional(number)
        vm_vfs_cache_pressure              = optional(number)
      }))
    }))
  }))
  default = {}
}

variable "identity" {
  description = "Identity configuration for the cluster"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = {
    type = "SystemAssigned"
  }
}

variable "service_principal" {
  description = "Service principal configuration"
  type = object({
    client_id     = string
    client_secret = string
  })
  default = null
}

variable "linux_profile" {
  description = "Linux profile configuration"
  type = object({
    admin_username = string
    ssh_key        = string
  })
  default = null
}

variable "windows_profile" {
  description = "Windows profile configuration"
  type = object({
    admin_username = string
    admin_password = string
    license        = optional(string)
    gmsa = optional(object({
      dns_server  = string
      root_domain = string
    }))
  })
  default = null
}

variable "network_profile" {
  description = "Network profile for the cluster"
  type = object({
    network_plugin    = optional(string, "kubenet")
    network_policy    = optional(string)
    dns_service_ip    = optional(string)
    docker_bridge_cidr = optional(string)
    outbound_type     = optional(string, "loadBalancer")
    pod_cidr          = optional(string)
    service_cidr      = optional(string)
    ip_versions       = optional(list(string), ["IPv4"])
    load_balancer_sku = optional(string, "standard")
    
    load_balancer_profile = optional(object({
      outbound_ports_allocated  = optional(number)
      idle_timeout_in_minutes   = optional(number)
      managed_outbound_ip_count = optional(number)
      outbound_ip_prefix_ids    = optional(list(string))
      outbound_ip_address_ids   = optional(list(string))
    }))
    
    nat_gateway_profile = optional(object({
      idle_timeout_in_minutes   = optional(number)
      managed_outbound_ip_count = optional(number)
    }))
  })
  default = {}
}

variable "api_server_access_profile" {
  description = "API server access profile"
  type = object({
    authorized_ip_ranges     = optional(list(string))
    subnet_id               = optional(string)
    vnet_integration_enabled = optional(bool, false)
  })
  default = {}
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy add-on"
  type        = bool
  default     = false
}

variable "http_application_routing_enabled" {
  description = "Enable HTTP application routing add-on"
  type        = bool
  default     = false
}

variable "oms_agent" {
  description = "OMS agent configuration"
  type = object({
    log_analytics_workspace_id      = string
    msi_auth_for_monitoring_enabled = optional(bool, false)
  })
  default = null
}

variable "ingress_application_gateway" {
  description = "Ingress Application Gateway configuration"
  type = object({
    gateway_id   = optional(string)
    gateway_name = optional(string)
    subnet_cidr  = optional(string)
    subnet_id    = optional(string)
  })
  default = null
}

variable "key_vault_secrets_provider" {
  description = "Key Vault secrets provider configuration"
  type = object({
    secret_rotation_enabled  = optional(bool, false)
    secret_rotation_interval = optional(string, "2m")
  })
  default = null
}

variable "auto_scaler_profile" {
  description = "Auto scaler profile configuration"
  type = object({
    balance_similar_node_groups      = optional(bool)
    expander                        = optional(string)
    max_graceful_termination_sec    = optional(string)
    max_node_provisioning_time      = optional(string)
    max_unready_nodes              = optional(number)
    max_unready_percentage         = optional(number)
    new_pod_scale_up_delay         = optional(string)
    scale_down_delay_after_add     = optional(string)
    scale_down_delay_after_delete  = optional(string)
    scale_down_delay_after_failure = optional(string)
    scan_interval                  = optional(string)
    scale_down_unneeded           = optional(string)
    scale_down_unready            = optional(string)
    scale_down_utilization_threshold = optional(string)
    empty_bulk_delete_max         = optional(string)
    skip_nodes_with_local_storage = optional(bool)
    skip_nodes_with_system_pods   = optional(bool)
  })
  default = null
}

variable "disk_encryption_set_id" {
  description = "Disk encryption set ID"
  type        = string
  default     = null
}

variable "http_proxy_config" {
  description = "HTTP proxy configuration"
  type = object({
    http_proxy  = optional(string)
    https_proxy = optional(string)
    no_proxy    = optional(list(string))
    trusted_ca  = optional(string)
  })
  default = null
}

variable "image_cleaner_enabled" {
  description = "Enable image cleaner"
  type        = bool
  default     = false
}

variable "image_cleaner_interval_hours" {
  description = "Image cleaner interval in hours"
  type        = number
  default     = 48
}

variable "workload_identity_enabled" {
  description = "Enable workload identity"
  type        = bool
  default     = false
}

variable "oidc_issuer_enabled" {
  description = "Enable OIDC issuer"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}