resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  
  node_resource_group = var.node_resource_group
  sku_tier           = var.sku_tier
  
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled

  default_node_pool {
    name                = var.default_node_pool.name
    node_count          = var.default_node_pool.node_count
    vm_size             = var.default_node_pool.vm_size
    vnet_subnet_id      = var.default_node_pool.vnet_subnet_id
    availability_zones  = var.default_node_pool.availability_zones
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count          = var.default_node_pool.min_count
    max_count          = var.default_node_pool.max_count
    max_pods           = var.default_node_pool.max_pods
    os_disk_size_gb    = var.default_node_pool.os_disk_size_gb
    os_disk_type       = var.default_node_pool.os_disk_type
    node_taints        = var.default_node_pool.node_taints
    node_labels        = var.default_node_pool.node_labels
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled
    orchestrator_version = var.default_node_pool.orchestrator_version
    proximity_placement_group_id = var.default_node_pool.proximity_placement_group_id
    scale_down_mode = var.default_node_pool.scale_down_mode
    type           = var.default_node_pool.type
    ultra_ssd_enabled = var.default_node_pool.ultra_ssd_enabled

    dynamic "upgrade_settings" {
      for_each = var.default_node_pool.upgrade_settings != null ? [var.default_node_pool.upgrade_settings] : []
      content {
        max_surge = upgrade_settings.value.max_surge
      }
    }

    dynamic "kubelet_config" {
      for_each = var.default_node_pool.kubelet_config != null ? [var.default_node_pool.kubelet_config] : []
      content {
        cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
        cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
        cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
        image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
        image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
        topology_manager_policy   = kubelet_config.value.topology_manager_policy
        allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
        container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
        container_log_max_line    = kubelet_config.value.container_log_max_line
        pod_max_pid               = kubelet_config.value.pod_max_pid
      }
    }

    dynamic "linux_os_config" {
      for_each = var.default_node_pool.linux_os_config != null ? [var.default_node_pool.linux_os_config] : []
      content {
        transparent_huge_page_enabled = linux_os_config.value.transparent_huge_page_enabled
        transparent_huge_page_defrag  = linux_os_config.value.transparent_huge_page_defrag
        swap_file_size_mb            = linux_os_config.value.swap_file_size_mb

        dynamic "sysctl_config" {
          for_each = linux_os_config.value.sysctl_config != null ? [linux_os_config.value.sysctl_config] : []
          content {
            fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
            fs_file_max                        = sysctl_config.value.fs_file_max
            fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
            fs_nr_open                         = sysctl_config.value.fs_nr_open
            kernel_threads_max                 = sysctl_config.value.kernel_threads_max
            net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
            net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
            net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
            net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
            net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
            net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
            net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
            net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
            net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
            net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
            net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
            net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
            net_ipv4_tcp_fin_timeout          = sysctl_config.value.net_ipv4_tcp_fin_timeout
            net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
            net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
            net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
            net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
            net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
            net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
            net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
            net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
            vm_max_map_count                   = sysctl_config.value.vm_max_map_count
            vm_swappiness                      = sysctl_config.value.vm_swappiness
            vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
          }
        }
      }
    }

    tags = var.tags
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "service_principal" {
    for_each = var.service_principal != null ? [var.service_principal] : []
    content {
      client_id     = service_principal.value.client_id
      client_secret = service_principal.value.client_secret
    }
  }

  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [var.linux_profile] : []
    content {
      admin_username = linux_profile.value.admin_username

      ssh_key {
        key_data = linux_profile.value.ssh_key
      }
    }
  }

  dynamic "windows_profile" {
    for_each = var.windows_profile != null ? [var.windows_profile] : []
    content {
      admin_username = windows_profile.value.admin_username
      admin_password = windows_profile.value.admin_password
      license        = windows_profile.value.license

      dynamic "gmsa" {
        for_each = windows_profile.value.gmsa != null ? [windows_profile.value.gmsa] : []
        content {
          dns_server  = gmsa.value.dns_server
          root_domain = gmsa.value.root_domain
        }
      }
    }
  }

  network_profile {
    network_plugin    = var.network_profile.network_plugin
    network_policy    = var.network_profile.network_policy
    dns_service_ip    = var.network_profile.dns_service_ip
    docker_bridge_cidr = var.network_profile.docker_bridge_cidr
    outbound_type     = var.network_profile.outbound_type
    pod_cidr          = var.network_profile.pod_cidr
    service_cidr      = var.network_profile.service_cidr
    ip_versions       = var.network_profile.ip_versions
    load_balancer_sku = var.network_profile.load_balancer_sku

    dynamic "load_balancer_profile" {
      for_each = var.network_profile.load_balancer_profile != null ? [var.network_profile.load_balancer_profile] : []
      content {
        outbound_ports_allocated  = load_balancer_profile.value.outbound_ports_allocated
        idle_timeout_in_minutes   = load_balancer_profile.value.idle_timeout_in_minutes
        managed_outbound_ip_count = load_balancer_profile.value.managed_outbound_ip_count
        outbound_ip_prefix_ids    = load_balancer_profile.value.outbound_ip_prefix_ids
        outbound_ip_address_ids   = load_balancer_profile.value.outbound_ip_address_ids
      }
    }

    dynamic "nat_gateway_profile" {
      for_each = var.network_profile.nat_gateway_profile != null ? [var.network_profile.nat_gateway_profile] : []
      content {
        idle_timeout_in_minutes   = nat_gateway_profile.value.idle_timeout_in_minutes
        managed_outbound_ip_count = nat_gateway_profile.value.managed_outbound_ip_count
      }
    }
  }

  dynamic "azure_policy_enabled" {
    for_each = var.azure_policy_enabled ? [1] : []
    content {}
  }

  dynamic "http_application_routing_enabled" {
    for_each = var.http_application_routing_enabled ? [1] : []
    content {}
  }

  dynamic "oms_agent" {
    for_each = var.oms_agent != null ? [var.oms_agent] : []
    content {
      log_analytics_workspace_id = oms_agent.value.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = oms_agent.value.msi_auth_for_monitoring_enabled
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway != null ? [var.ingress_application_gateway] : []
    content {
      gateway_id   = ingress_application_gateway.value.gateway_id
      gateway_name = ingress_application_gateway.value.gateway_name
      subnet_cidr  = ingress_application_gateway.value.subnet_cidr
      subnet_id    = ingress_application_gateway.value.subnet_id
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider != null ? [var.key_vault_secrets_provider] : []
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile != null ? [var.auto_scaler_profile] : []
    content {
      balance_similar_node_groups      = auto_scaler_profile.value.balance_similar_node_groups
      expander                        = auto_scaler_profile.value.expander
      max_graceful_termination_sec    = auto_scaler_profile.value.max_graceful_termination_sec
      max_node_provisioning_time      = auto_scaler_profile.value.max_node_provisioning_time
      max_unready_nodes              = auto_scaler_profile.value.max_unready_nodes
      max_unready_percentage         = auto_scaler_profile.value.max_unready_percentage
      new_pod_scale_up_delay         = auto_scaler_profile.value.new_pod_scale_up_delay
      scale_down_delay_after_add     = auto_scaler_profile.value.scale_down_delay_after_add
      scale_down_delay_after_delete  = auto_scaler_profile.value.scale_down_delay_after_delete
      scale_down_delay_after_failure = auto_scaler_profile.value.scale_down_delay_after_failure
      scan_interval                  = auto_scaler_profile.value.scan_interval
      scale_down_unneeded           = auto_scaler_profile.value.scale_down_unneeded
      scale_down_unready = auto_scaler_profile.value.scale_down_unready
      scale_down_utilization_threshold = auto_scaler_profile.value.scale_down_utilization_threshold
      empty_bulk_delete_max         = auto_scaler_profile.value.empty_bulk_delete_max
      skip_nodes_with_local_storage = auto_scaler_profile.value.skip_nodes_with_local_storage
      skip_nodes_with_system_pods   = auto_scaler_profile.value.skip_nodes_with_system_pods
    }
  }

  api_server_access_profile {
    authorized_ip_ranges     = var.api_server_access_profile.authorized_ip_ranges
    subnet_id               = var.api_server_access_profile.subnet_id
    vnet_integration_enabled = var.api_server_access_profile.vnet_integration_enabled
  }

  disk_encryption_set_id      = var.disk_encryption_set_id
  http_proxy_config          = var.http_proxy_config
  image_cleaner_enabled      = var.image_cleaner_enabled
  image_cleaner_interval_hours = var.image_cleaner_interval_hours
  workload_identity_enabled  = var.workload_identity_enabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "additional_node_pools" {
  for_each = var.additional_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size              = each.value.vm_size
  node_count           = each.value.node_count
  availability_zones   = each.value.availability_zones
  enable_auto_scaling  = each.value.enable_auto_scaling
  min_count           = each.value.min_count
  max_count           = each.value.max_count
  max_pods            = each.value.max_pods
  mode                = each.value.mode
  node_labels         = each.value.node_labels
  node_taints         = each.value.node_taints
  orchestrator_version = each.value.orchestrator_version
  os_disk_size_gb     = each.value.os_disk_size_gb
  os_disk_type        = each.value.os_disk_type
  os_type             = each.value.os_type
  priority            = each.value.priority
  proximity_placement_group_id = each.value.proximity_placement_group_id
  spot_max_price      = each.value.spot_max_price
  ultra_ssd_enabled   = each.value.ultra_ssd_enabled
  vnet_subnet_id      = each.value.vnet_subnet_id
  zones               = each.value.zones
  eviction_policy     = each.value.eviction_policy
  scale_down_mode     = each.value.scale_down_mode
  snapshot_id         = each.value.snapshot_id

  dynamic "upgrade_settings" {
    for_each = each.value.upgrade_settings != null ? [each.value.upgrade_settings] : []
    content {
      max_surge = upgrade_settings.value.max_surge
    }
  }

  dynamic "kubelet_config" {
    for_each = each.value.kubelet_config != null ? [each.value.kubelet_config] : []
    content {
      cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
      cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
      cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
      image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
      image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
      topology_manager_policy   = kubelet_config.value.topology_manager_policy
      allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
      container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
      container_log_max_line    = kubelet_config.value.container_log_max_line
      pod_max_pid               = kubelet_config.value.pod_max_pid
    }
  }

  dynamic "linux_os_config" {
    for_each = each.value.linux_os_config != null ? [each.value.linux_os_config] : []
    content {
      transparent_huge_page_enabled = linux_os_config.value.transparent_huge_page_enabled
      transparent_huge_page_defrag  = linux_os_config.value.transparent_huge_page_defrag
      swap_file_size_mb            = linux_os_config.value.swap_file_size_mb

      dynamic "sysctl_config" {
        for_each = linux_os_config.value.sysctl_config != null ? [linux_os_config.value.sysctl_config] : []
        content {
          fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
          fs_file_max                        = sysctl_config.value.fs_file_max
          fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
          fs_nr_open                         = sysctl_config.value.fs_nr_open
          kernel_threads_max                 = sysctl_config.value.kernel_threads_max
          net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
          net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
          net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
          net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
          net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
          net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
          net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
          net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
          net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
          net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
          net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
          net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
          net_ipv4_tcp_fin_timeout          = sysctl_config.value.net_ipv4_tcp_fin_timeout
          net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
          net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
          net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
          net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
          net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
          net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
          net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
          net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
          vm_max_map_count                   = sysctl_config.value.vm_max_map_count
          vm_swappiness                      = sysctl_config.value.vm_swappiness
          vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
        }
      }
    }
  }

  tags = var.tags
}