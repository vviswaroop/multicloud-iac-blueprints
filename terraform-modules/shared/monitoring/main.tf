# Shared Monitoring Module - Main Configuration
# Cloud-agnostic monitoring with Prometheus/Grafana

# Random passwords for Grafana admin
resource "random_password" "grafana_admin_password" {
  count   = var.create_grafana_admin_password ? 1 : 0
  length  = var.grafana_admin_password_length
  special = true
}

# Kubernetes namespace for monitoring
resource "kubernetes_namespace" "monitoring" {
  count = var.create_monitoring_namespace ? 1 : 0

  metadata {
    name = var.monitoring_namespace
    labels = merge(var.monitoring_namespace_labels, {
      "app.kubernetes.io/name"       = "monitoring"
      "app.kubernetes.io/component"  = "monitoring"
      "app.kubernetes.io/managed-by" = "terraform"
    })
    annotations = var.monitoring_namespace_annotations
  }
}

# Prometheus Service Account
resource "kubernetes_service_account" "prometheus" {
  count = var.deploy_prometheus ? 1 : 0

  metadata {
    name      = var.prometheus_service_account_name
    namespace = local.monitoring_namespace
    labels = merge(var.prometheus_labels, {
      "app.kubernetes.io/name"       = "prometheus"
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/managed-by" = "terraform"
    })
    annotations = var.prometheus_service_account_annotations
  }

  automount_service_account_token = true
}

# Prometheus ClusterRole
resource "kubernetes_cluster_role" "prometheus" {
  count = var.deploy_prometheus ? 1 : 0

  metadata {
    name = var.prometheus_cluster_role_name
    labels = merge(var.prometheus_labels, {
      "app.kubernetes.io/name"       = "prometheus"
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/managed-by" = "terraform"
    })
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "services", "endpoints", "pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
}

# Prometheus ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "prometheus" {
  count = var.deploy_prometheus ? 1 : 0

  metadata {
    name = var.prometheus_cluster_role_binding_name
    labels = merge(var.prometheus_labels, {
      "app.kubernetes.io/name"       = "prometheus"
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/managed-by" = "terraform"
    })
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.prometheus[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus[0].metadata[0].name
    namespace = local.monitoring_namespace
  }
}

# Prometheus ConfigMap
resource "kubernetes_config_map" "prometheus_config" {
  count = var.deploy_prometheus ? 1 : 0

  metadata {
    name      = var.prometheus_config_map_name
    namespace = local.monitoring_namespace
    labels = merge(var.prometheus_labels, {
      "app.kubernetes.io/name"       = "prometheus"
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/managed-by" = "terraform"
    })
  }

  data = {
    "prometheus.yml" = templatefile("${path.module}/templates/prometheus.yml.tpl", {
      scrape_configs        = var.prometheus_scrape_configs
      global_config         = var.prometheus_global_config
      rule_files            = var.prometheus_rule_files
      alerting_config       = var.prometheus_alerting_config
      remote_write_configs  = var.prometheus_remote_write_configs
      remote_read_configs   = var.prometheus_remote_read_configs
    })
  }
}

# Prometheus Deployment
resource "kubernetes_deployment" "prometheus" {
  count = var.deploy_prometheus ? 1 : 0

  metadata {
    name      = var.prometheus_deployment_name
    namespace = local.monitoring_namespace
    labels = merge(var.prometheus_labels, {
      "app.kubernetes.io/name"       = "prometheus"
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/managed-by" = "terraform"
    })
  }

  spec {
    replicas = var.prometheus_replicas

    selector {
      match_labels = {
        "app.kubernetes.io/name"      = "prometheus"
        "app.kubernetes.io/component" = "server"
      }
    }

    template {
      metadata {
        labels = merge(var.prometheus_labels, {
          "app.kubernetes.io/name"      = "prometheus"
          "app.kubernetes.io/component" = "server"
        })
        annotations = var.prometheus_pod_annotations
      }

      spec {
        service_account_name = kubernetes_service_account.prometheus[0].metadata[0].name
        security_context {
          fs_group = 65534
        }

        container {
          name  = "prometheus"
          image = "${var.prometheus_image}:${var.prometheus_image_tag}"

          args = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.path=/prometheus/",
            "--web.console.libraries=/etc/prometheus/console_libraries",
            "--web.console.templates=/etc/prometheus/consoles",
            "--web.enable-lifecycle",
            "--storage.tsdb.retention.time=${var.prometheus_retention_time}",
            "--storage.tsdb.retention.size=${var.prometheus_retention_size}",
            "--web.listen-address=0.0.0.0:9090"
          ]

          port {
            container_port = 9090
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/prometheus/"
          }

          volume_mount {
            name       = "prometheus-storage"
            mount_path = "/prometheus/"
          }

          resources {
            requests = var.prometheus_resources.requests
            limits   = var.prometheus_resources.limits
          }

          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = 9090
            }
            initial_delay_seconds = 30
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = 9090
            }
            initial_delay_seconds = 5
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }
        }

        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.prometheus_config[0].metadata[0].name
          }
        }

        volume {
          name = "prometheus-storage"
          dynamic "persistent_volume_claim" {
            for_each = var.prometheus_persistence_enabled ? [1] : []
            content {
              claim_name = kubernetes_persistent_volume_claim.prometheus_storage[0].metadata[0].name
            }
          }
          dynamic "empty_dir" {
            for_each = var.prometheus_persistence_enabled ? [] : [1]
            content {}
          }
        }

        node_selector = var.prometheus_node_selector
        tolerations {
          key      = var.prometheus_tolerations.key
          operator = var.prometheus_tolerations.operator
          value    = var.prometheus_tolerations.value
          effect   = var.prometheus_tolerations.effect
        }
      }
    }
  }
}

# Prometheus PVC
resource "kubernetes_persistent_volume_claim" "prometheus_storage" {
  count = var.deploy_prometheus && var.prometheus_persistence_enabled ? 1 : 0

  metadata {
    name      = var.prometheus_pvc_name
    namespace = local.monitoring_namespace
    labels = merge(var.prometheus_labels, {
      "app.kubernetes.io/name"       = "prometheus"
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/managed-by" = "terraform"
    })
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.prometheus_storage_size
      }
    }
    storage_class_name = var.prometheus_storage_class
  }
}

# Prometheus Service
resource "kubernetes_service" "prometheus" {
  count = var.deploy_prometheus ? 1 : 0

  metadata {
    name      = var.prometheus_service_name
    namespace = local.monitoring_namespace
    labels = merge(var.prometheus_labels, {
      "app.kubernetes.io/name"       = "prometheus"
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/managed-by" = "terraform"
    })
    annotations = var.prometheus_service_annotations
  }

  spec {
    selector = {
      "app.kubernetes.io/name"      = "prometheus"
      "app.kubernetes.io/component" = "server"
    }

    port {
      name        = "http"
      port        = 9090
      target_port = 9090
      protocol    = "TCP"
    }

    type = var.prometheus_service_type
  }
}

# Grafana Service Account
resource "kubernetes_service_account" "grafana" {
  count = var.deploy_grafana ? 1 : 0

  metadata {
    name      = var.grafana_service_account_name
    namespace = local.monitoring_namespace
    labels = merge(var.grafana_labels, {
      "app.kubernetes.io/name"       = "grafana"
      "app.kubernetes.io/component"  = "grafana"
      "app.kubernetes.io/managed-by" = "terraform"
    })
    annotations = var.grafana_service_account_annotations
  }
}

# Grafana Secret
resource "kubernetes_secret" "grafana_admin" {
  count = var.deploy_grafana ? 1 : 0

  metadata {
    name      = var.grafana_secret_name
    namespace = local.monitoring_namespace
    labels = merge(var.grafana_labels, {
      "app.kubernetes.io/name"       = "grafana"
      "app.kubernetes.io/component"  = "grafana"
      "app.kubernetes.io/managed-by" = "terraform"
    })
  }

  type = "Opaque"

  data = {
    admin-user     = var.grafana_admin_user
    admin-password = var.create_grafana_admin_password ? random_password.grafana_admin_password[0].result : var.grafana_admin_password
  }
}

# Grafana ConfigMap
resource "kubernetes_config_map" "grafana_config" {
  count = var.deploy_grafana ? 1 : 0

  metadata {
    name      = var.grafana_config_map_name
    namespace = local.monitoring_namespace
    labels = merge(var.grafana_labels, {
      "app.kubernetes.io/name"       = "grafana"
      "app.kubernetes.io/component"  = "grafana"
      "app.kubernetes.io/managed-by" = "terraform"
    })
  }

  data = {
    "grafana.ini" = templatefile("${path.module}/templates/grafana.ini.tpl", {
      grafana_config = var.grafana_config
    })
    "datasources.yaml" = templatefile("${path.module}/templates/datasources.yaml.tpl", {
      datasources = var.grafana_datasources
    })
  }
}

# Grafana Dashboards ConfigMap
resource "kubernetes_config_map" "grafana_dashboards" {
  count = var.deploy_grafana && length(var.grafana_dashboards) > 0 ? 1 : 0

  metadata {
    name      = var.grafana_dashboards_config_map_name
    namespace = local.monitoring_namespace
    labels = merge(var.grafana_labels, {
      "app.kubernetes.io/name"       = "grafana"
      "app.kubernetes.io/component"  = "grafana"
      "app.kubernetes.io/managed-by" = "terraform"
      "grafana_dashboard"            = "1"
    })
  }

  data = var.grafana_dashboards
}

# Grafana Deployment
resource "kubernetes_deployment" "grafana" {
  count = var.deploy_grafana ? 1 : 0

  metadata {
    name      = var.grafana_deployment_name
    namespace = local.monitoring_namespace
    labels = merge(var.grafana_labels, {
      "app.kubernetes.io/name"       = "grafana"
      "app.kubernetes.io/component"  = "grafana"
      "app.kubernetes.io/managed-by" = "terraform"
    })
  }

  spec {
    replicas = var.grafana_replicas

    selector {
      match_labels = {
        "app.kubernetes.io/name"      = "grafana"
        "app.kubernetes.io/component" = "grafana"
      }
    }

    template {
      metadata {
        labels = merge(var.grafana_labels, {
          "app.kubernetes.io/name"      = "grafana"
          "app.kubernetes.io/component" = "grafana"
        })
        annotations = var.grafana_pod_annotations
      }

      spec {
        service_account_name = kubernetes_service_account.grafana[0].metadata[0].name
        security_context {
          fs_group = 472
        }

        container {
          name  = "grafana"
          image = "${var.grafana_image}:${var.grafana_image_tag}"

          env {
            name = "GF_SECURITY_ADMIN_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.grafana_admin[0].metadata[0].name
                key  = "admin-user"
              }
            }
          }

          env {
            name = "GF_SECURITY_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.grafana_admin[0].metadata[0].name
                key  = "admin-password"
              }
            }
          }

          port {
            container_port = 3000
          }

          volume_mount {
            name       = "grafana-config"
            mount_path = "/etc/grafana/"
          }

          volume_mount {
            name       = "grafana-datasources"
            mount_path = "/etc/grafana/provisioning/datasources/"
          }

          volume_mount {
            name       = "grafana-storage"
            mount_path = "/var/lib/grafana"
          }

          dynamic "volume_mount" {
            for_each = length(var.grafana_dashboards) > 0 ? [1] : []
            content {
              name       = "grafana-dashboards"
              mount_path = "/var/lib/grafana/dashboards"
            }
          }

          resources {
            requests = var.grafana_resources.requests
            limits   = var.grafana_resources.limits
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 30
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 5
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }
        }

        volume {
          name = "grafana-config"
          config_map {
            name = kubernetes_config_map.grafana_config[0].metadata[0].name
          }
        }

        volume {
          name = "grafana-datasources"
          config_map {
            name = kubernetes_config_map.grafana_config[0].metadata[0].name
          }
        }

        volume {
          name = "grafana-storage"
          dynamic "persistent_volume_claim" {
            for_each = var.grafana_persistence_enabled ? [1] : []
            content {
              claim_name = kubernetes_persistent_volume_claim.grafana_storage[0].metadata[0].name
            }
          }
          dynamic "empty_dir" {
            for_each = var.grafana_persistence_enabled ? [] : [1]
            content {}
          }
        }

        dynamic "volume" {
          for_each = length(var.grafana_dashboards) > 0 ? [1] : []
          content {
            name = "grafana-dashboards"
            config_map {
              name = kubernetes_config_map.grafana_dashboards[0].metadata[0].name
            }
          }
        }

        node_selector = var.grafana_node_selector
        tolerations {
          key      = var.grafana_tolerations.key
          operator = var.grafana_tolerations.operator
          value    = var.grafana_tolerations.value
          effect   = var.grafana_tolerations.effect
        }
      }
    }
  }
}

# Grafana PVC
resource "kubernetes_persistent_volume_claim" "grafana_storage" {
  count = var.deploy_grafana && var.grafana_persistence_enabled ? 1 : 0

  metadata {
    name      = var.grafana_pvc_name
    namespace = local.monitoring_namespace
    labels = merge(var.grafana_labels, {
      "app.kubernetes.io/name"       = "grafana"
      "app.kubernetes.io/component"  = "grafana"
      "app.kubernetes.io/managed-by" = "terraform"
    })
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.grafana_storage_size
      }
    }
    storage_class_name = var.grafana_storage_class
  }
}

# Grafana Service
resource "kubernetes_service" "grafana" {
  count = var.deploy_grafana ? 1 : 0

  metadata {
    name      = var.grafana_service_name
    namespace = local.monitoring_namespace
    labels = merge(var.grafana_labels, {
      "app.kubernetes.io/name"       = "grafana"
      "app.kubernetes.io/component"  = "grafana"
      "app.kubernetes.io/managed-by" = "terraform"
    })
    annotations = var.grafana_service_annotations
  }

  spec {
    selector = {
      "app.kubernetes.io/name"      = "grafana"
      "app.kubernetes.io/component" = "grafana"
    }

    port {
      name        = "http"
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }

    type = var.grafana_service_type
  }
}

# AlertManager deployment (optional)
resource "kubernetes_deployment" "alertmanager" {
  count = var.deploy_alertmanager ? 1 : 0

  metadata {
    name      = var.alertmanager_deployment_name
    namespace = local.monitoring_namespace
    labels = merge(var.alertmanager_labels, {
      "app.kubernetes.io/name"       = "alertmanager"
      "app.kubernetes.io/component"  = "alertmanager"
      "app.kubernetes.io/managed-by" = "terraform"
    })
  }

  spec {
    replicas = var.alertmanager_replicas

    selector {
      match_labels = {
        "app.kubernetes.io/name"      = "alertmanager"
        "app.kubernetes.io/component" = "alertmanager"
      }
    }

    template {
      metadata {
        labels = merge(var.alertmanager_labels, {
          "app.kubernetes.io/name"      = "alertmanager"
          "app.kubernetes.io/component" = "alertmanager"
        })
        annotations = var.alertmanager_pod_annotations
      }

      spec {
        container {
          name  = "alertmanager"
          image = "${var.alertmanager_image}:${var.alertmanager_image_tag}"

          args = [
            "--config.file=/etc/alertmanager/alertmanager.yml",
            "--storage.path=/alertmanager",
            "--web.external-url=http://localhost:9093",
            "--web.route-prefix=/",
            "--cluster.listen-address=0.0.0.0:9094"
          ]

          port {
            container_port = 9093
          }

          volume_mount {
            name       = "alertmanager-config"
            mount_path = "/etc/alertmanager/"
          }

          volume_mount {
            name       = "alertmanager-storage"
            mount_path = "/alertmanager"
          }

          resources {
            requests = var.alertmanager_resources.requests
            limits   = var.alertmanager_resources.limits
          }
        }

        volume {
          name = "alertmanager-config"
          config_map {
            name = kubernetes_config_map.alertmanager_config[0].metadata[0].name
          }
        }

        volume {
          name = "alertmanager-storage"
          empty_dir {}
        }
      }
    }
  }
}

# AlertManager ConfigMap
resource "kubernetes_config_map" "alertmanager_config" {
  count = var.deploy_alertmanager ? 1 : 0

  metadata {
    name      = var.alertmanager_config_map_name
    namespace = local.monitoring_namespace
    labels = merge(var.alertmanager_labels, {
      "app.kubernetes.io/name"       = "alertmanager"
      "app.kubernetes.io/component"  = "alertmanager"
      "app.kubernetes.io/managed-by" = "terraform"
    })
  }

  data = {
    "alertmanager.yml" = templatefile("${path.module}/templates/alertmanager.yml.tpl", {
      alertmanager_config = var.alertmanager_config
    })
  }
}

# AlertManager Service
resource "kubernetes_service" "alertmanager" {
  count = var.deploy_alertmanager ? 1 : 0

  metadata {
    name      = var.alertmanager_service_name
    namespace = local.monitoring_namespace
    labels = merge(var.alertmanager_labels, {
      "app.kubernetes.io/name"       = "alertmanager"
      "app.kubernetes.io/component"  = "alertmanager"
      "app.kubernetes.io/managed-by" = "terraform"
    })
    annotations = var.alertmanager_service_annotations
  }

  spec {
    selector = {
      "app.kubernetes.io/name"      = "alertmanager"
      "app.kubernetes.io/component" = "alertmanager"
    }

    port {
      name        = "http"
      port        = 9093
      target_port = 9093
      protocol    = "TCP"
    }

    type = var.alertmanager_service_type
  }
}

# Local variables
locals {
  monitoring_namespace = var.create_monitoring_namespace ? kubernetes_namespace.monitoring[0].metadata[0].name : var.monitoring_namespace
}