# Shared Monitoring Module - Variables

# General Configuration
variable "monitoring_namespace" {
  description = "The Kubernetes namespace to deploy monitoring components to"
  type        = string
  default     = "monitoring"
}

variable "create_monitoring_namespace" {
  description = "Whether to create the monitoring namespace"
  type        = bool
  default     = true
}

variable "monitoring_namespace_labels" {
  description = "Labels to apply to the monitoring namespace"
  type        = map(string)
  default     = {}
}

variable "monitoring_namespace_annotations" {
  description = "Annotations to apply to the monitoring namespace"
  type        = map(string)
  default     = {}
}

# Prometheus Configuration
variable "deploy_prometheus" {
  description = "Whether to deploy Prometheus"
  type        = bool
  default     = true
}

variable "prometheus_image" {
  description = "Prometheus container image"
  type        = string
  default     = "prom/prometheus"
}

variable "prometheus_image_tag" {
  description = "Prometheus container image tag"
  type        = string
  default     = "v2.45.0"
}

variable "prometheus_replicas" {
  description = "Number of Prometheus replicas"
  type        = number
  default     = 1
}

variable "prometheus_service_account_name" {
  description = "Name of the Prometheus service account"
  type        = string
  default     = "prometheus"
}

variable "prometheus_service_account_annotations" {
  description = "Annotations for the Prometheus service account"
  type        = map(string)
  default     = {}
}

variable "prometheus_cluster_role_name" {
  description = "Name of the Prometheus cluster role"
  type        = string
  default     = "prometheus"
}

variable "prometheus_cluster_role_binding_name" {
  description = "Name of the Prometheus cluster role binding"
  type        = string
  default     = "prometheus"
}

variable "prometheus_config_map_name" {
  description = "Name of the Prometheus config map"
  type        = string
  default     = "prometheus-config"
}

variable "prometheus_deployment_name" {
  description = "Name of the Prometheus deployment"
  type        = string
  default     = "prometheus"
}

variable "prometheus_service_name" {
  description = "Name of the Prometheus service"
  type        = string
  default     = "prometheus"
}

variable "prometheus_service_type" {
  description = "Type of Prometheus service"
  type        = string
  default     = "ClusterIP"
  validation {
    condition     = contains(["ClusterIP", "NodePort", "LoadBalancer"], var.prometheus_service_type)
    error_message = "Prometheus service type must be ClusterIP, NodePort, or LoadBalancer."
  }
}

variable "prometheus_service_annotations" {
  description = "Annotations for the Prometheus service"
  type        = map(string)
  default     = {}
}

variable "prometheus_labels" {
  description = "Labels to apply to all Prometheus resources"
  type        = map(string)
  default     = {}
}

variable "prometheus_pod_annotations" {
  description = "Annotations for Prometheus pods"
  type        = map(string)
  default     = {}
}

variable "prometheus_resources" {
  description = "Resource limits and requests for Prometheus"
  type = object({
    requests = optional(map(string), {
      cpu    = "250m"
      memory = "512Mi"
    })
    limits = optional(map(string), {
      cpu    = "1000m"
      memory = "2Gi"
    })
  })
  default = {
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
    limits = {
      cpu    = "1000m"
      memory = "2Gi"
    }
  }
}

variable "prometheus_retention_time" {
  description = "How long to retain metrics"
  type        = string
  default     = "15d"
}

variable "prometheus_retention_size" {
  description = "Maximum amount of bytes that can be stored for blocks"
  type        = string
  default     = "10GB"
}

variable "prometheus_persistence_enabled" {
  description = "Enable persistence for Prometheus"
  type        = bool
  default     = true
}

variable "prometheus_storage_size" {
  description = "Size of Prometheus persistent volume"
  type        = string
  default     = "20Gi"
}

variable "prometheus_storage_class" {
  description = "Storage class for Prometheus persistent volume"
  type        = string
  default     = null
}

variable "prometheus_pvc_name" {
  description = "Name of the Prometheus PVC"
  type        = string
  default     = "prometheus-storage"
}

variable "prometheus_node_selector" {
  description = "Node selector for Prometheus pods"
  type        = map(string)
  default     = {}
}

variable "prometheus_tolerations" {
  description = "Tolerations for Prometheus pods"
  type = object({
    key      = optional(string)
    operator = optional(string, "Equal")
    value    = optional(string)
    effect   = optional(string)
  })
  default = {
    key      = null
    operator = "Equal"
    value    = null
    effect   = null
  }
}

# Prometheus Configuration
variable "prometheus_global_config" {
  description = "Global configuration for Prometheus"
  type        = map(any)
  default = {
    scrape_interval     = "15s"
    evaluation_interval = "15s"
  }
}

variable "prometheus_rule_files" {
  description = "List of rule files for Prometheus"
  type        = list(string)
  default     = []
}

variable "prometheus_scrape_configs" {
  description = "Scrape configurations for Prometheus"
  type = list(object({
    job_name        = string
    scrape_interval = optional(string, "30s")
    metrics_path    = optional(string, "/metrics")
    targets         = list(string)
    labels          = optional(map(string), {})
    relabel_configs = optional(list(object({
      source_labels = list(string)
      target_label  = string
      regex         = string
      replacement   = string
      action        = string
    })), [])
  }))
  default = [
    {
      job_name = "prometheus"
      targets  = ["localhost:9090"]
    },
    {
      job_name = "kubernetes-apiservers"
      targets  = ["kubernetes.default.svc:443"]
      labels = {
        __scheme__              = "https"
        __metrics_path__        = "/metrics"
        __param_module          = "http_2xx"
      }
    },
    {
      job_name = "kubernetes-nodes"
      targets  = []
      labels = {
        __address__ = "kubernetes.default.svc:443"
        __scheme__  = "https"
      }
    }
  ]
}

variable "prometheus_alerting_config" {
  description = "Alerting configuration for Prometheus"
  type = list(object({
    targets = list(string)
  }))
  default = []
}

variable "prometheus_remote_write_configs" {
  description = "Remote write configurations for Prometheus"
  type = list(object({
    name = string
    url  = string
    basic_auth = optional(object({
      username = string
      password = string
    }))
    headers = optional(map(string), {})
  }))
  default = []
}

variable "prometheus_remote_read_configs" {
  description = "Remote read configurations for Prometheus"
  type = list(object({
    name = string
    url  = string
    basic_auth = optional(object({
      username = string
      password = string
    }))
    headers = optional(map(string), {})
  }))
  default = []
}

# Grafana Configuration
variable "deploy_grafana" {
  description = "Whether to deploy Grafana"
  type        = bool
  default     = true
}

variable "grafana_image" {
  description = "Grafana container image"
  type        = string
  default     = "grafana/grafana"
}

variable "grafana_image_tag" {
  description = "Grafana container image tag"
  type        = string
  default     = "10.0.0"
}

variable "grafana_replicas" {
  description = "Number of Grafana replicas"
  type        = number
  default     = 1
}

variable "grafana_service_account_name" {
  description = "Name of the Grafana service account"
  type        = string
  default     = "grafana"
}

variable "grafana_service_account_annotations" {
  description = "Annotations for the Grafana service account"
  type        = map(string)
  default     = {}
}

variable "grafana_secret_name" {
  description = "Name of the Grafana secret"
  type        = string
  default     = "grafana-admin"
}

variable "grafana_config_map_name" {
  description = "Name of the Grafana config map"
  type        = string
  default     = "grafana-config"
}

variable "grafana_dashboards_config_map_name" {
  description = "Name of the Grafana dashboards config map"
  type        = string
  default     = "grafana-dashboards"
}

variable "grafana_deployment_name" {
  description = "Name of the Grafana deployment"
  type        = string
  default     = "grafana"
}

variable "grafana_service_name" {
  description = "Name of the Grafana service"
  type        = string
  default     = "grafana"
}

variable "grafana_service_type" {
  description = "Type of Grafana service"
  type        = string
  default     = "ClusterIP"
  validation {
    condition     = contains(["ClusterIP", "NodePort", "LoadBalancer"], var.grafana_service_type)
    error_message = "Grafana service type must be ClusterIP, NodePort, or LoadBalancer."
  }
}

variable "grafana_service_annotations" {
  description = "Annotations for the Grafana service"
  type        = map(string)
  default     = {}
}

variable "grafana_labels" {
  description = "Labels to apply to all Grafana resources"
  type        = map(string)
  default     = {}
}

variable "grafana_pod_annotations" {
  description = "Annotations for Grafana pods"
  type        = map(string)
  default     = {}
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "create_grafana_admin_password" {
  description = "Whether to create a random admin password for Grafana"
  type        = bool
  default     = true
}

variable "grafana_admin_password" {
  description = "Grafana admin password (if not auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "grafana_admin_password_length" {
  description = "Length of the auto-generated Grafana admin password"
  type        = number
  default     = 16
}

variable "grafana_resources" {
  description = "Resource limits and requests for Grafana"
  type = object({
    requests = optional(map(string), {
      cpu    = "100m"
      memory = "128Mi"
    })
    limits = optional(map(string), {
      cpu    = "500m"
      memory = "512Mi"
    })
  })
  default = {
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
  }
}

variable "grafana_persistence_enabled" {
  description = "Enable persistence for Grafana"
  type        = bool
  default     = true
}

variable "grafana_storage_size" {
  description = "Size of Grafana persistent volume"
  type        = string
  default     = "10Gi"
}

variable "grafana_storage_class" {
  description = "Storage class for Grafana persistent volume"
  type        = string
  default     = null
}

variable "grafana_pvc_name" {
  description = "Name of the Grafana PVC"
  type        = string
  default     = "grafana-storage"
}

variable "grafana_node_selector" {
  description = "Node selector for Grafana pods"
  type        = map(string)
  default     = {}
}

variable "grafana_tolerations" {
  description = "Tolerations for Grafana pods"
  type = object({
    key      = optional(string)
    operator = optional(string, "Equal")
    value    = optional(string)
    effect   = optional(string)
  })
  default = {
    key      = null
    operator = "Equal"
    value    = null
    effect   = null
  }
}

variable "grafana_config" {
  description = "Grafana configuration sections"
  type        = map(map(any))
  default = {
    server = {
      http_port = 3000
      domain    = "localhost"
    }
    database = {
      type = "sqlite3"
      path = "grafana.db"
    }
    security = {
      admin_user     = "$${GF_SECURITY_ADMIN_USER}"
      admin_password = "$${GF_SECURITY_ADMIN_PASSWORD}"
    }
  }
}

variable "grafana_datasources" {
  description = "Grafana datasources configuration"
  type = list(object({
    name                = string
    type                = string
    access              = optional(string, "proxy")
    url                 = string
    is_default          = optional(bool, false)
    basic_auth_enabled  = optional(bool, false)
    basic_auth_user     = optional(string)
    basic_auth_password = optional(string)
    json_data           = optional(map(any), {})
    secure_json_data    = optional(map(string), {})
  }))
  default = [
    {
      name       = "Prometheus"
      type       = "prometheus"
      url        = "http://prometheus:9090"
      is_default = true
    }
  ]
}

variable "grafana_dashboards" {
  description = "Grafana dashboards as JSON strings"
  type        = map(string)
  default     = {}
}

# AlertManager Configuration
variable "deploy_alertmanager" {
  description = "Whether to deploy AlertManager"
  type        = bool
  default     = false
}

variable "alertmanager_image" {
  description = "AlertManager container image"
  type        = string
  default     = "prom/alertmanager"
}

variable "alertmanager_image_tag" {
  description = "AlertManager container image tag"
  type        = string
  default     = "v0.25.0"
}

variable "alertmanager_replicas" {
  description = "Number of AlertManager replicas"
  type        = number
  default     = 1
}

variable "alertmanager_deployment_name" {
  description = "Name of the AlertManager deployment"
  type        = string
  default     = "alertmanager"
}

variable "alertmanager_config_map_name" {
  description = "Name of the AlertManager config map"
  type        = string
  default     = "alertmanager-config"
}

variable "alertmanager_service_name" {
  description = "Name of the AlertManager service"
  type        = string
  default     = "alertmanager"
}

variable "alertmanager_service_type" {
  description = "Type of AlertManager service"
  type        = string
  default     = "ClusterIP"
  validation {
    condition     = contains(["ClusterIP", "NodePort", "LoadBalancer"], var.alertmanager_service_type)
    error_message = "AlertManager service type must be ClusterIP, NodePort, or LoadBalancer."
  }
}

variable "alertmanager_service_annotations" {
  description = "Annotations for the AlertManager service"
  type        = map(string)
  default     = {}
}

variable "alertmanager_labels" {
  description = "Labels to apply to all AlertManager resources"
  type        = map(string)
  default     = {}
}

variable "alertmanager_pod_annotations" {
  description = "Annotations for AlertManager pods"
  type        = map(string)
  default     = {}
}

variable "alertmanager_resources" {
  description = "Resource limits and requests for AlertManager"
  type = object({
    requests = optional(map(string), {
      cpu    = "100m"
      memory = "128Mi"
    })
    limits = optional(map(string), {
      cpu    = "500m"
      memory = "512Mi"
    })
  })
  default = {
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
  }
}

variable "alertmanager_config" {
  description = "AlertManager configuration"
  type = object({
    global = optional(map(any), {
      smtp_smarthost = "localhost:587"
      smtp_from      = "alertmanager@example.org"
    })
    templates = optional(list(string), [])
    route = object({
      group_by        = list(string)
      group_wait      = string
      group_interval  = string
      repeat_interval = string
      receiver        = string
      routes = optional(list(object({
        match           = map(string)
        receiver        = string
        group_wait      = optional(string)
        group_interval  = optional(string)
        repeat_interval = optional(string)
      })), [])
    })
    receivers = list(object({
      name = string
      email_configs = optional(list(object({
        to            = string
        from          = string
        smarthost     = string
        subject       = optional(string, "{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}")
        body          = optional(string, "{{ range .Alerts }}{{ .Annotations.description }}{{ end }}")
        auth_username = optional(string)
        auth_password = optional(string)
      })), [])
      slack_configs = optional(list(object({
        api_url = string
        channel = string
        title   = optional(string, "{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}")
        text    = optional(string, "{{ range .Alerts }}{{ .Annotations.description }}{{ end }}")
      })), [])
      webhook_configs = optional(list(object({
        url           = string
        send_resolved = optional(bool, true)
      })), [])
    }))
    inhibit_rules = optional(list(object({
      source_match = map(string)
      target_match = map(string)
      equal        = list(string)
    })), [])
  })
  default = {
    route = {
      group_by        = ["alertname"]
      group_wait      = "10s"
      group_interval  = "10s"
      repeat_interval = "1h"
      receiver        = "web.hook"
    }
    receivers = [
      {
        name = "web.hook"
      }
    ]
  }
}