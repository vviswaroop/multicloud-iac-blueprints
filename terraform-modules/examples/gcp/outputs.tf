# GCP Microservices Platform - Outputs

# Project Information
output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "project_name" {
  description = "The project name used for resource naming"
  value       = var.project_name
}

output "environment" {
  description = "The environment name"
  value       = var.environment
}

output "region" {
  description = "The GCP region"
  value       = var.region
}

# VPC Network Outputs
output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = module.vpc.network_name
}

output "vpc_network_self_link" {
  description = "Self-link of the VPC network"
  value       = module.vpc.network_self_link
}

output "vpc_network_id" {
  description = "ID of the VPC network"
  value       = module.vpc.network_id
}

output "subnets" {
  description = "Information about created subnets"
  value = {
    gke_subnet = {
      name       = "${var.project_name}-gke-subnet-${var.environment}"
      ip_range   = var.gke_subnet_cidr
      region     = var.region
      self_link  = module.vpc.subnets_self_links[0]
    }
    private_subnet = {
      name       = "${var.project_name}-private-subnet-${var.environment}"
      ip_range   = var.private_subnet_cidr
      region     = var.region
      self_link  = module.vpc.subnets_self_links[1]
    }
    mgmt_subnet = {
      name       = "${var.project_name}-mgmt-subnet-${var.environment}"
      ip_range   = var.mgmt_subnet_cidr
      region     = var.region
      self_link  = module.vpc.subnets_self_links[2]
    }
  }
}

output "secondary_ranges" {
  description = "Secondary IP ranges for GKE"
  value = {
    pods_range = {
      name      = "${var.project_name}-gke-pods-${var.environment}"
      ip_range  = var.gke_pods_cidr
    }
    services_range = {
      name      = "${var.project_name}-gke-services-${var.environment}"
      ip_range  = var.gke_services_cidr
    }
  }
}

# GKE Cluster Outputs
output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "Endpoint of the GKE cluster"
  value       = module.gke.endpoint
  sensitive   = true
}

output "gke_cluster_location" {
  description = "Location of the GKE cluster"
  value       = module.gke.location
}

output "gke_cluster_master_version" {
  description = "Master version of the GKE cluster"
  value       = module.gke.master_version
}

output "gke_cluster_ca_certificate" {
  description = "CA certificate of the GKE cluster"
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "gke_node_pools" {
  description = "Information about GKE node pools"
  value = {
    general = {
      name         = "general"
      machine_type = var.gke_machine_type
      node_count   = var.gke_node_count
      disk_size    = 100
      disk_type    = "pd-ssd"
      preemptible  = var.environment != "prod"
    }
    high_memory = {
      name         = "high-memory"
      machine_type = var.gke_high_memory_machine_type
      node_count   = 0
      disk_size    = 100
      disk_type    = "pd-ssd"
      preemptible  = var.environment != "prod"
    }
  }
}

# kubectl connection command
output "gke_get_credentials_command" {
  description = "Command to configure kubectl for the cluster"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}"
}

# Cloud SQL Outputs
output "cloudsql_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = module.cloudsql.instance_name
}

output "cloudsql_connection_name" {
  description = "Connection name for the Cloud SQL instance"
  value       = module.cloudsql.connection_name
}

output "cloudsql_private_ip" {
  description = "Private IP address of the Cloud SQL instance"
  value       = module.cloudsql.private_ip_address
}

output "cloudsql_databases" {
  description = "List of databases created"
  value = [
    "postgres",  # Default database
    "users_service",
    "orders_service",
    "inventory_service",
    "payments_service",
    "notifications_service"
  ]
}

output "cloudsql_users" {
  description = "Database users created (passwords not shown for security)"
  value = {
    root_user     = module.cloudsql.root_user_name
    backend_user  = "app_backend_user"
    readonly_user = "readonly_user"
  }
  sensitive = true
}

output "cloudsql_connection_info" {
  description = "Cloud SQL connection information for applications"
  value = {
    host     = module.cloudsql.private_ip_address
    port     = 5432
    database = "postgres"
    ssl_mode = "require"
  }
}

# Cloud SQL Proxy connection command
output "cloudsql_proxy_command" {
  description = "Command to connect via Cloud SQL Proxy"
  value       = "cloud-sql-proxy ${module.cloudsql.connection_name} --private-ip"
}

# Service Account Outputs
output "service_accounts" {
  description = "Created service accounts"
  value = {
    gke_cluster  = "${local.service_accounts.gke_cluster}@${var.project_id}.iam.gserviceaccount.com"
    gke_nodes    = "${local.service_accounts.gke_nodes}@${var.project_id}.iam.gserviceaccount.com"
    cloudsql     = "${local.service_accounts.cloudsql}@${var.project_id}.iam.gserviceaccount.com"
    app_backend  = "${local.service_accounts.app_backend}@${var.project_id}.iam.gserviceaccount.com"
    app_frontend = "${local.service_accounts.app_frontend}@${var.project_id}.iam.gserviceaccount.com"
    monitoring   = "${local.service_accounts.monitoring}@${var.project_id}.iam.gserviceaccount.com"
  }
}

# Storage Outputs
output "storage_buckets" {
  description = "Created storage buckets"
  value = {
    app_data = {
      name     = module.storage.bucket_name
      url      = module.storage.bucket_url
      location = module.storage.bucket_location
    }
    backups = {
      name     = module.backup_storage.bucket_name
      url      = module.backup_storage.bucket_url
      location = module.backup_storage.bucket_location
    }
  }
}

# Bastion Host Outputs
output "bastion_instance" {
  description = "Bastion host information"
  value = {
    name        = module.bastion.instance_name
    zone        = module.bastion.instance_zone
    internal_ip = module.bastion.internal_ip
    external_ip = module.bastion.external_ip
  }
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion host"
  value       = "gcloud compute ssh ${module.bastion.instance_name} --zone=${module.bastion.instance_zone} --project=${var.project_id}"
}

# Application Deployment Information
output "deployment_info" {
  description = "Information for deploying applications"
  value = {
    kubernetes_context = "${var.project_id}_${var.region}_${module.gke.cluster_name}"
    docker_registry   = "${var.region}-docker.pkg.dev/${var.project_id}/${var.project_name}-${var.environment}"
    ingress_class     = "gce"
    cert_manager      = "letsencrypt-prod"
  }
}

# Monitoring and Observability
output "monitoring_info" {
  description = "Monitoring and observability endpoints"
  value = {
    gcp_monitoring_url = "https://console.cloud.google.com/monitoring/overview?project=${var.project_id}"
    gcp_logging_url    = "https://console.cloud.google.com/logs/viewer?project=${var.project_id}"
    gke_workloads_url  = "https://console.cloud.google.com/kubernetes/workload/overview?project=${var.project_id}"
    cloudsql_url       = "https://console.cloud.google.com/sql/instances?project=${var.project_id}"
  }
}

# Security Information
output "security_info" {
  description = "Security-related information"
  value = {
    workload_identity_enabled = true
    private_cluster_enabled   = true
    network_policy_enabled    = var.enable_network_policy
    binary_authorization      = var.environment == "prod" ? "enabled" : "disabled"
    master_authorized_networks = [
      {
        cidr_block   = var.mgmt_subnet_cidr
        display_name = "Management Subnet"
      },
      {
        cidr_block   = var.authorized_networks_cidr
        display_name = "Authorized Networks"
      }
    ]
  }
}

# Networking Information
output "networking_info" {
  description = "Networking configuration details"
  value = {
    vpc_cidr           = var.vpc_cidr
    gke_subnet_cidr    = var.gke_subnet_cidr
    gke_pods_cidr      = var.gke_pods_cidr
    gke_services_cidr  = var.gke_services_cidr
    gke_master_cidr    = var.gke_master_cidr
    private_subnet_cidr = var.private_subnet_cidr
    mgmt_subnet_cidr   = var.mgmt_subnet_cidr
  }
}

# Cost Optimization Information
output "cost_optimization" {
  description = "Cost optimization features enabled"
  value = {
    preemptible_nodes_enabled    = var.enable_preemptible_nodes
    cluster_autoscaling_enabled  = var.enable_cluster_autoscaling
    min_node_count              = var.min_node_count
    max_node_count              = var.max_node_count
    estimated_monthly_cost_usd  = "See GCP Billing Console for actual costs"
  }
}

# Quick Start Commands
output "quick_start_commands" {
  description = "Quick start commands for common operations"
  value = {
    configure_kubectl = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}"
    ssh_to_bastion   = "gcloud compute ssh ${module.bastion.instance_name} --zone=${module.bastion.instance_zone} --project=${var.project_id}"
    connect_to_sql   = "cloud-sql-proxy ${module.cloudsql.connection_name} --private-ip"
    view_logs        = "gcloud logging read 'resource.type=\"k8s_container\"' --project=${var.project_id} --limit=50"
    list_services    = "kubectl get services --all-namespaces"
    port_forward_example = "kubectl port-forward service/your-service 8080:80"
  }
}

# Important Notes
output "important_notes" {
  description = "Important notes and next steps"
  value = {
    database_passwords = "Database passwords are stored in Terraform state. Consider using Google Secret Manager for production."
    ssl_certificates   = "Configure SSL certificates for your domains using cert-manager or Google-managed certificates."
    backup_strategy    = "Implement application-level backups in addition to Cloud SQL automated backups."
    monitoring_setup   = "Deploy monitoring stack (Prometheus, Grafana) to the GKE cluster for application metrics."
    ci_cd_setup       = "Set up CI/CD pipelines using Cloud Build or GitHub Actions for automated deployments."
    dns_configuration  = "Configure DNS records to point to the load balancer created by Kubernetes ingress."
    security_scanning  = "Enable vulnerability scanning for container images in Artifact Registry."
  }
}