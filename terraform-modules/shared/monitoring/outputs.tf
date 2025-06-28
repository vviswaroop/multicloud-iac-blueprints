# Shared Monitoring Module - Outputs

# Namespace Information
output "monitoring_namespace" {
  description = "The namespace where monitoring components are deployed"
  value       = local.monitoring_namespace
}

# Prometheus Information
output "prometheus_deployed" {
  description = "Whether Prometheus is deployed"
  value       = var.deploy_prometheus
}

output "prometheus_service_name" {
  description = "The name of the Prometheus service"
  value       = var.deploy_prometheus ? kubernetes_service.prometheus[0].metadata[0].name : null
}

output "prometheus_service_namespace" {
  description = "The namespace of the Prometheus service"
  value       = var.deploy_prometheus ? kubernetes_service.prometheus[0].metadata[0].namespace : null
}

output "prometheus_service_port" {
  description = "The port of the Prometheus service"
  value       = var.deploy_prometheus ? kubernetes_service.prometheus[0].spec[0].port[0].port : null
}

output "prometheus_endpoint" {
  description = "The internal endpoint for Prometheus"
  value       = var.deploy_prometheus ? "http://${kubernetes_service.prometheus[0].metadata[0].name}.${local.monitoring_namespace}.svc.cluster.local:9090" : null
}

output "prometheus_deployment_name" {
  description = "The name of the Prometheus deployment"
  value       = var.deploy_prometheus ? kubernetes_deployment.prometheus[0].metadata[0].name : null
}

output "prometheus_service_account_name" {
  description = "The name of the Prometheus service account"
  value       = var.deploy_prometheus ? kubernetes_service_account.prometheus[0].metadata[0].name : null
}

output "prometheus_config_map_name" {
  description = "The name of the Prometheus config map"
  value       = var.deploy_prometheus ? kubernetes_config_map.prometheus_config[0].metadata[0].name : null
}

output "prometheus_pvc_name" {
  description = "The name of the Prometheus PVC"
  value       = var.deploy_prometheus && var.prometheus_persistence_enabled ? kubernetes_persistent_volume_claim.prometheus_storage[0].metadata[0].name : null
}

output "prometheus_storage_size" {
  description = "The size of the Prometheus storage"
  value       = var.deploy_prometheus && var.prometheus_persistence_enabled ? var.prometheus_storage_size : null
}

# Grafana Information
output "grafana_deployed" {
  description = "Whether Grafana is deployed"
  value       = var.deploy_grafana
}

output "grafana_service_name" {
  description = "The name of the Grafana service"
  value       = var.deploy_grafana ? kubernetes_service.grafana[0].metadata[0].name : null
}

output "grafana_service_namespace" {
  description = "The namespace of the Grafana service"
  value       = var.deploy_grafana ? kubernetes_service.grafana[0].metadata[0].namespace : null
}

output "grafana_service_port" {
  description = "The port of the Grafana service"
  value       = var.deploy_grafana ? kubernetes_service.grafana[0].spec[0].port[0].port : null
}

output "grafana_endpoint" {
  description = "The internal endpoint for Grafana"
  value       = var.deploy_grafana ? "http://${kubernetes_service.grafana[0].metadata[0].name}.${local.monitoring_namespace}.svc.cluster.local:3000" : null
}

output "grafana_deployment_name" {
  description = "The name of the Grafana deployment"
  value       = var.deploy_grafana ? kubernetes_deployment.grafana[0].metadata[0].name : null
}

output "grafana_service_account_name" {
  description = "The name of the Grafana service account"
  value       = var.deploy_grafana ? kubernetes_service_account.grafana[0].metadata[0].name : null
}

output "grafana_config_map_name" {
  description = "The name of the Grafana config map"
  value       = var.deploy_grafana ? kubernetes_config_map.grafana_config[0].metadata[0].name : null
}

output "grafana_admin_user" {
  description = "The Grafana admin username"
  value       = var.deploy_grafana ? var.grafana_admin_user : null
}

output "grafana_admin_password" {
  description = "The Grafana admin password"
  value       = var.deploy_grafana && var.create_grafana_admin_password ? random_password.grafana_admin_password[0].result : null
  sensitive   = true
}

output "grafana_secret_name" {
  description = "The name of the Grafana admin secret"
  value       = var.deploy_grafana ? kubernetes_secret.grafana_admin[0].metadata[0].name : null
}

output "grafana_pvc_name" {
  description = "The name of the Grafana PVC"
  value       = var.deploy_grafana && var.grafana_persistence_enabled ? kubernetes_persistent_volume_claim.grafana_storage[0].metadata[0].name : null
}

output "grafana_storage_size" {
  description = "The size of the Grafana storage"
  value       = var.deploy_grafana && var.grafana_persistence_enabled ? var.grafana_storage_size : null
}

output "grafana_dashboards_config_map_name" {
  description = "The name of the Grafana dashboards config map"
  value       = var.deploy_grafana && length(var.grafana_dashboards) > 0 ? kubernetes_config_map.grafana_dashboards[0].metadata[0].name : null
}

# AlertManager Information
output "alertmanager_deployed" {
  description = "Whether AlertManager is deployed"
  value       = var.deploy_alertmanager
}

output "alertmanager_service_name" {
  description = "The name of the AlertManager service"
  value       = var.deploy_alertmanager ? kubernetes_service.alertmanager[0].metadata[0].name : null
}

output "alertmanager_service_namespace" {
  description = "The namespace of the AlertManager service"
  value       = var.deploy_alertmanager ? kubernetes_service.alertmanager[0].metadata[0].namespace : null
}

output "alertmanager_service_port" {
  description = "The port of the AlertManager service"
  value       = var.deploy_alertmanager ? kubernetes_service.alertmanager[0].spec[0].port[0].port : null
}

output "alertmanager_endpoint" {
  description = "The internal endpoint for AlertManager"
  value       = var.deploy_alertmanager ? "http://${kubernetes_service.alertmanager[0].metadata[0].name}.${local.monitoring_namespace}.svc.cluster.local:9093" : null
}

output "alertmanager_deployment_name" {
  description = "The name of the AlertManager deployment"
  value       = var.deploy_alertmanager ? kubernetes_deployment.alertmanager[0].metadata[0].name : null
}

output "alertmanager_config_map_name" {
  description = "The name of the AlertManager config map"
  value       = var.deploy_alertmanager ? kubernetes_config_map.alertmanager_config[0].metadata[0].name : null
}

# Monitoring Stack Information
output "monitoring_stack_components" {
  description = "List of deployed monitoring components"
  value = compact([
    var.deploy_prometheus ? "prometheus" : "",
    var.deploy_grafana ? "grafana" : "",
    var.deploy_alertmanager ? "alertmanager" : ""
  ])
}

output "monitoring_endpoints" {
  description = "Map of monitoring service endpoints"
  value = {
    prometheus    = var.deploy_prometheus ? "http://${kubernetes_service.prometheus[0].metadata[0].name}.${local.monitoring_namespace}.svc.cluster.local:9090" : null
    grafana       = var.deploy_grafana ? "http://${kubernetes_service.grafana[0].metadata[0].name}.${local.monitoring_namespace}.svc.cluster.local:3000" : null
    alertmanager  = var.deploy_alertmanager ? "http://${kubernetes_service.alertmanager[0].metadata[0].name}.${local.monitoring_namespace}.svc.cluster.local:9093" : null
  }
}

output "monitoring_service_names" {
  description = "Map of monitoring service names"
  value = {
    prometheus   = var.deploy_prometheus ? kubernetes_service.prometheus[0].metadata[0].name : null
    grafana      = var.deploy_grafana ? kubernetes_service.grafana[0].metadata[0].name : null
    alertmanager = var.deploy_alertmanager ? kubernetes_service.alertmanager[0].metadata[0].name : null
  }
}

# Configuration Information
output "prometheus_scrape_configs_count" {
  description = "Number of configured Prometheus scrape configs"
  value       = length(var.prometheus_scrape_configs)
}

output "grafana_datasources_count" {
  description = "Number of configured Grafana datasources"
  value       = length(var.grafana_datasources)
}

output "grafana_dashboards_count" {
  description = "Number of configured Grafana dashboards"
  value       = length(var.grafana_dashboards)
}

# Resource Information
output "prometheus_resources" {
  description = "Prometheus resource configuration"
  value       = var.deploy_prometheus ? var.prometheus_resources : null
}

output "grafana_resources" {
  description = "Grafana resource configuration"
  value       = var.deploy_grafana ? var.grafana_resources : null
}

output "alertmanager_resources" {
  description = "AlertManager resource configuration"
  value       = var.deploy_alertmanager ? var.alertmanager_resources : null
}