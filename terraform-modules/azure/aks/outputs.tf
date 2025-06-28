output "cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "private_fqdn" {
  description = "Private FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.private_fqdn
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.main.kube_config
  sensitive   = true
}

output "kube_config_raw" {
  description = "Raw Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "kubelet_identity" {
  description = "Kubelet identity"
  value       = azurerm_kubernetes_cluster.main.kubelet_identity
}

output "cluster_identity" {
  description = "Cluster identity"
  value       = azurerm_kubernetes_cluster.main.identity
}

output "node_resource_group" {
  description = "Node resource group name"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "kubernetes_version" {
  description = "Kubernetes version"
  value       = azurerm_kubernetes_cluster.main.kubernetes_version
}

output "default_node_pool_id" {
  description = "ID of the default node pool"
  value       = azurerm_kubernetes_cluster.main.default_node_pool[0].name
}

output "additional_node_pools" {
  description = "Information about additional node pools"
  value = {
    for k, v in azurerm_kubernetes_cluster_node_pool.additional_node_pools : k => {
      id               = v.id
      name             = v.name
      vm_size          = v.vm_size
      node_count       = v.node_count
      max_pods         = v.max_pods
      os_type          = v.os_type
      orchestrator_version = v.orchestrator_version
    }
  }
}

output "network_profile" {
  description = "Network profile configuration"
  value       = azurerm_kubernetes_cluster.main.network_profile
}

output "api_server_access_profile" {
  description = "API server access profile"
  value       = azurerm_kubernetes_cluster.main.api_server_access_profile
}

output "portal_fqdn" {
  description = "Portal FQDN"
  value       = azurerm_kubernetes_cluster.main.portal_fqdn
}

output "http_application_routing_zone_name" {
  description = "HTTP application routing zone name"
  value       = var.http_application_routing_enabled ? azurerm_kubernetes_cluster.main.http_application_routing_zone_name : null
}

output "oms_agent_identity" {
  description = "OMS agent identity"
  value       = var.oms_agent != null ? azurerm_kubernetes_cluster.main.oms_agent[0].oms_agent_identity : null
}

output "ingress_application_gateway" {
  description = "Ingress Application Gateway configuration"
  value       = var.ingress_application_gateway != null ? azurerm_kubernetes_cluster.main.ingress_application_gateway : null
}

output "key_vault_secrets_provider" {
  description = "Key Vault secrets provider configuration"
  value       = var.key_vault_secrets_provider != null ? azurerm_kubernetes_cluster.main.key_vault_secrets_provider : null
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL"
  value       = var.oidc_issuer_enabled ? azurerm_kubernetes_cluster.main.oidc_issuer_url : null
}

output "current_kubernetes_version" {
  description = "Current Kubernetes version"
  value       = azurerm_kubernetes_cluster.main.current_kubernetes_version
}

output "location" {
  description = "Location of the cluster"
  value       = azurerm_kubernetes_cluster.main.location
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_kubernetes_cluster.main.resource_group_name
}