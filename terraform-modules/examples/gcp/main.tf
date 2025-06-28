# GCP Microservices Architecture Example
# Production-ready microservices application with GKE, Cloud SQL, and proper IAM setup

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Local variables for consistent naming and tagging
locals {
  common_labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
    application = "microservices-platform"
  }

  # Service accounts for different components
  service_accounts = {
    gke_cluster   = "${var.project_name}-gke-cluster-${var.environment}"
    gke_nodes     = "${var.project_name}-gke-nodes-${var.environment}"
    cloudsql      = "${var.project_name}-cloudsql-${var.environment}"
    app_backend   = "${var.project_name}-app-backend-${var.environment}"
    app_frontend  = "${var.project_name}-app-frontend-${var.environment}"
    monitoring    = "${var.project_name}-monitoring-${var.environment}"
  }
}

# Random suffix for unique resource naming
resource "random_id" "suffix" {
  byte_length = 4
}

# VPC Network for the microservices platform
module "vpc" {
  source = "../../gcp/vpc"

  name                      = "${var.project_name}-vpc-${var.environment}"
  project_id               = var.project_id
  auto_create_subnetworks  = false
  routing_mode            = "REGIONAL"
  enable_flow_logs        = true
  flow_log_sampling       = 0.1
  flow_log_interval       = "INTERVAL_5_MIN"

  # Subnets for different tiers
  subnets = [
    # GKE cluster subnet
    {
      name                     = "${var.project_name}-gke-subnet-${var.environment}"
      ip_cidr_range           = var.gke_subnet_cidr
      region                  = var.region
      private_ip_google_access = true
      secondary_ip_ranges = [
        {
          range_name    = "${var.project_name}-gke-pods-${var.environment}"
          ip_cidr_range = var.gke_pods_cidr
        },
        {
          range_name    = "${var.project_name}-gke-services-${var.environment}"
          ip_cidr_range = var.gke_services_cidr
        }
      ]
    },
    # Private subnet for databases and internal services
    {
      name                     = "${var.project_name}-private-subnet-${var.environment}"
      ip_cidr_range           = var.private_subnet_cidr
      region                  = var.region
      private_ip_google_access = true
    },
    # Management subnet for bastion and monitoring
    {
      name                     = "${var.project_name}-mgmt-subnet-${var.environment}"
      ip_cidr_range           = var.mgmt_subnet_cidr
      region                  = var.region
      private_ip_google_access = true
    }
  ]

  # Firewall rules for secure communication
  firewall_rules = [
    # Allow internal communication within VPC
    {
      name        = "${var.project_name}-allow-internal-${var.environment}"
      description = "Allow internal communication within VPC"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = [var.vpc_cidr]
      allow = [
        {
          protocol = "tcp"
          ports    = ["0-65535"]
        },
        {
          protocol = "udp"
          ports    = ["0-65535"]
        },
        {
          protocol = "icmp"
        }
      ]
    },
    # Allow SSH from management subnet
    {
      name        = "${var.project_name}-allow-ssh-mgmt-${var.environment}"
      description = "Allow SSH access from management subnet"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = [var.mgmt_subnet_cidr]
      target_tags = ["ssh-access"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
    },
    # Allow HTTPS ingress to GKE
    {
      name        = "${var.project_name}-allow-https-ingress-${var.environment}"
      description = "Allow HTTPS traffic to GKE ingress"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["0.0.0.0/0"]
      target_tags = ["gke-ingress"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["443", "80"]
        }
      ]
    },
    # Allow health checks
    {
      name        = "${var.project_name}-allow-health-checks-${var.environment}"
      description = "Allow Google Cloud health checks"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["130.211.0.0/22", "35.191.0.0/16"]
      target_tags = ["gke-node"]
      allow = [
        {
          protocol = "tcp"
        }
      ]
    }
  ]

  labels = local.common_labels
}

# IAM Configuration for service accounts and permissions
module "iam" {
  source = "../../gcp/iam"

  project_id = var.project_id

  # Service accounts for different components
  service_accounts = {
    (local.service_accounts.gke_cluster) = {
      display_name = "GKE Cluster Service Account"
      description  = "Service account for GKE cluster management"
    }
    (local.service_accounts.gke_nodes) = {
      display_name = "GKE Nodes Service Account"
      description  = "Service account for GKE worker nodes"
    }
    (local.service_accounts.cloudsql) = {
      display_name = "Cloud SQL Proxy Service Account"
      description  = "Service account for Cloud SQL proxy connections"
    }
    (local.service_accounts.app_backend) = {
      display_name = "Application Backend Service Account"
      description  = "Service account for backend microservices"
    }
    (local.service_accounts.app_frontend) = {
      display_name = "Application Frontend Service Account"
      description  = "Service account for frontend applications"
    }
    (local.service_accounts.monitoring) = {
      display_name = "Monitoring Service Account"
      description  = "Service account for monitoring and observability"
    }
  }

  # Project-level IAM bindings
  project_iam_bindings = {
    # GKE Cluster service account permissions
    "roles/container.clusterAdmin" = {
      members = ["serviceAccount:${local.service_accounts.gke_cluster}@${var.project_id}.iam.gserviceaccount.com"]
    }
    "roles/compute.networkAdmin" = {
      members = ["serviceAccount:${local.service_accounts.gke_cluster}@${var.project_id}.iam.gserviceaccount.com"]
    }
    "roles/container.hostServiceAgentUser" = {
      members = ["serviceAccount:${local.service_accounts.gke_cluster}@${var.project_id}.iam.gserviceaccount.com"]
    }

    # GKE Nodes service account permissions
    "roles/storage.objectViewer" = {
      members = [
        "serviceAccount:${local.service_accounts.gke_nodes}@${var.project_id}.iam.gserviceaccount.com",
        "serviceAccount:${local.service_accounts.app_backend}@${var.project_id}.iam.gserviceaccount.com"
      ]
    }
    "roles/logging.logWriter" = {
      members = [
        "serviceAccount:${local.service_accounts.gke_nodes}@${var.project_id}.iam.gserviceaccount.com",
        "serviceAccount:${local.service_accounts.app_backend}@${var.project_id}.iam.gserviceaccount.com",
        "serviceAccount:${local.service_accounts.monitoring}@${var.project_id}.iam.gserviceaccount.com"
      ]
    }
    "roles/monitoring.metricWriter" = {
      members = [
        "serviceAccount:${local.service_accounts.gke_nodes}@${var.project_id}.iam.gserviceaccount.com",
        "serviceAccount:${local.service_accounts.monitoring}@${var.project_id}.iam.gserviceaccount.com"
      ]
    }
    "roles/monitoring.viewer" = {
      members = [
        "serviceAccount:${local.service_accounts.monitoring}@${var.project_id}.iam.gserviceaccount.com"
      ]
    }

    # Cloud SQL permissions
    "roles/cloudsql.client" = {
      members = [
        "serviceAccount:${local.service_accounts.cloudsql}@${var.project_id}.iam.gserviceaccount.com",
        "serviceAccount:${local.service_accounts.app_backend}@${var.project_id}.iam.gserviceaccount.com"
      ]
    }
  }
}

# Cloud SQL PostgreSQL instance for application data
module "cloudsql" {
  source = "../../gcp/cloudsql"

  project_id          = var.project_id
  instance_name       = "${var.project_name}-postgres-${var.environment}-${random_id.suffix.hex}"
  database_version    = "POSTGRES_15"
  region             = var.region
  tier               = var.cloudsql_tier
  availability_type  = var.environment == "prod" ? "REGIONAL" : "ZONAL"
  disk_size          = var.cloudsql_disk_size
  disk_type          = "PD_SSD"
  disk_autoresize    = true
  disk_autoresize_limit = var.cloudsql_disk_size * 2

  # Network configuration for private IP
  private_network    = module.vpc.network_self_link
  ipv4_enabled      = false
  require_ssl       = true

  # Backup configuration
  backup_enabled                 = true
  backup_start_time             = "02:00"
  point_in_time_recovery_enabled = true
  backup_retained_backups       = var.environment == "prod" ? 30 : 7

  # Maintenance window (Sunday 3 AM)
  maintenance_window_day         = 1
  maintenance_window_hour        = 3
  maintenance_window_update_track = var.environment == "prod" ? "stable" : "canary"

  # Enable query insights for monitoring
  query_insights_enabled = true
  record_application_tags = true
  record_client_address  = true

  # Additional databases for microservices
  additional_databases = [
    "users_service",
    "orders_service",
    "inventory_service",
    "payments_service",
    "notifications_service"
  ]

  # Application users with appropriate permissions
  additional_users = {
    "app_backend_user" = {
      type     = "BUILT_IN"
      password = var.db_backend_password
    }
    "readonly_user" = {
      type     = "BUILT_IN"
      password = var.db_readonly_password
    }
  }

  # Read replica for analytics workloads (production only)
  read_replicas = var.environment == "prod" ? {
    "analytics-replica" = {
      region               = var.replica_region
      tier                = var.cloudsql_replica_tier
      availability_type    = "ZONAL"
      private_network     = module.vpc.network_self_link
      ipv4_enabled        = false
    }
  } : {}

  user_labels       = local.common_labels
  deletion_protection = var.environment == "prod" ? true : false
}

# GKE Cluster for microservices
module "gke" {
  source = "../../gcp/gke"

  project_id       = var.project_id
  cluster_name     = "${var.project_name}-gke-${var.environment}"
  location         = var.region
  description      = "GKE cluster for ${var.project_name} microservices platform"

  # Network configuration
  network    = module.vpc.network_name
  subnetwork = "${var.project_name}-gke-subnet-${var.environment}"

  # IP allocation for pods and services
  ip_allocation_policy = {
    cluster_secondary_range_name  = "${var.project_name}-gke-pods-${var.environment}"
    services_secondary_range_name = "${var.project_name}-gke-services-${var.environment}"
  }

  # Private cluster configuration
  private_cluster_config = {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.gke_master_cidr
    master_global_access_config = {
      enabled = true
    }
  }

  # Master authorized networks
  master_authorized_networks_config = {
    gcp_public_cidrs_access_enabled = false
    cidr_blocks = [
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

  # Enable essential addons
  http_load_balancing_disabled         = false
  horizontal_pod_autoscaling_disabled  = false
  network_policy_disabled             = false
  dns_cache_enabled                   = true
  gce_pd_csi_driver_enabled          = true
  gke_backup_agent_enabled           = true
  config_connector_enabled           = false

  # Network policy
  network_policy_enabled  = true
  network_policy_provider = "CALICO"

  # Workload Identity
  workload_identity_enabled = true

  # Cluster autoscaling
  cluster_autoscaling = {
    enabled = true
    resource_limits = [
      {
        resource_type = "cpu"
        minimum       = 4
        maximum       = 100
      },
      {
        resource_type = "memory"
        minimum       = 16
        maximum       = 400
      }
    ]
  }

  # Maintenance policy
  maintenance_policy = {
    daily_maintenance_window = {
      start_time = "04:00"
    }
  }

  # Logging and monitoring
  logging_enabled_components    = ["SYSTEM_COMPONENTS", "WORKLOADS", "API_SERVER"]
  monitoring_enabled_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  managed_prometheus_enabled    = true

  # Security features
  security_posture_enabled              = true
  security_posture_mode                = "BASIC"
  binary_authorization_enabled         = var.environment == "prod"
  binary_authorization_evaluation_mode = var.environment == "prod" ? "PROJECT_SINGLETON_POLICY_ENFORCE" : "DISABLED"

  # Node pools for different workload types
  node_pools = {
    # General purpose node pool for most workloads
    "general" = {
      node_count   = var.gke_node_count
      machine_type = var.gke_machine_type
      disk_size_gb = 100
      disk_type    = "pd-ssd"
      image_type   = "COS_CONTAINERD"
      preemptible  = var.environment != "prod"

      autoscaling = {
        min_node_count = var.environment == "prod" ? 2 : 1
        max_node_count = var.environment == "prod" ? 10 : 5
      }

      management = {
        auto_repair  = true
        auto_upgrade = true
      }

      shielded_instance_config = {
        enable_secure_boot          = true
        enable_integrity_monitoring = true
      }

      workload_metadata_config = {
        mode = "GKE_METADATA"
      }

      labels = merge(local.common_labels, {
        node_pool = "general"
      })

      tags = ["gke-node", "general-pool"]
    }

    # High-memory node pool for memory-intensive workloads
    "high-memory" = {
      node_count   = 0  # Start with 0, scale up as needed
      machine_type = var.gke_high_memory_machine_type
      disk_size_gb = 100
      disk_type    = "pd-ssd"
      image_type   = "COS_CONTAINERD"
      preemptible  = var.environment != "prod"

      autoscaling = {
        min_node_count = 0
        max_node_count = var.environment == "prod" ? 5 : 2
      }

      management = {
        auto_repair  = true
        auto_upgrade = true
      }

      taints = [
        {
          key    = "workload-type"
          value  = "high-memory"
          effect = "NO_SCHEDULE"
        }
      ]

      labels = merge(local.common_labels, {
        node_pool    = "high-memory"
        workload_type = "high-memory"
      })

      tags = ["gke-node", "high-memory-pool"]
    }
  }

  resource_labels = local.common_labels
  deletion_protection = var.environment == "prod"

  depends_on = [
    module.vpc,
    module.iam
  ]
}

# Cloud Storage buckets for application data
module "storage" {
  source = "../../gcp/storage"

  bucket_name    = "${var.project_name}-app-data-${var.environment}-${random_id.suffix.hex}"
  project_id     = var.project_id
  location       = var.region
  storage_class  = "STANDARD"
  
  versioning_enabled         = true
  uniform_bucket_level_access = true
  force_destroy             = var.environment != "prod"

  # Lifecycle management
  lifecycle_rules = [
    {
      condition = {
        age = 30
        with_state = "NONCURRENT"
      }
      action = {
        type = "Delete"
      }
    },
    {
      condition = {
        age = 90
        matches_storage_class = ["STANDARD"]
      }
      action = {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
    }
  ]

  # CORS configuration for web applications
  cors_rules = [
    {
      origin  = ["https://*.${var.domain_name}", "https://${var.domain_name}"]
      method  = ["GET", "POST", "PUT", "DELETE", "HEAD"]
      response_header = ["Content-Type", "Authorization"]
      max_age_seconds = 3600
    }
  ]

  # IAM permissions
  iam_bindings = {
    "roles/storage.objectViewer" = {
      members = [
        "serviceAccount:${local.service_accounts.app_frontend}@${var.project_id}.iam.gserviceaccount.com",
        "serviceAccount:${local.service_accounts.app_backend}@${var.project_id}.iam.gserviceaccount.com"
      ]
    }
    "roles/storage.objectCreator" = {
      members = [
        "serviceAccount:${local.service_accounts.app_backend}@${var.project_id}.iam.gserviceaccount.com"
      ]
    }
  }

  labels = local.common_labels
}

# Additional storage bucket for backups
module "backup_storage" {
  source = "../../gcp/storage"

  bucket_name    = "${var.project_name}-backups-${var.environment}-${random_id.suffix.hex}"
  project_id     = var.project_id
  location       = var.region
  storage_class  = "COLDLINE"
  
  versioning_enabled         = true
  uniform_bucket_level_access = true
  force_destroy             = var.environment != "prod"

  # Long-term retention for backups
  lifecycle_rules = [
    {
      condition = {
        age = 365
      }
      action = {
        type          = "SetStorageClass"
        storage_class = "ARCHIVE"
      }
    },
    {
      condition = {
        age = 2555  # 7 years
      }
      action = {
        type = "Delete"
      }
    }
  ]

  # IAM permissions for backup operations
  iam_bindings = {
    "roles/storage.objectAdmin" = {
      members = [
        "serviceAccount:${local.service_accounts.app_backend}@${var.project_id}.iam.gserviceaccount.com"
      ]
    }
  }

  labels = merge(local.common_labels, {
    purpose = "backups"
  })
}

# Compute Engine instance for bastion host (management access)
module "bastion" {
  source = "../../gcp/compute"

  project_id    = var.project_id
  instance_name = "${var.project_name}-bastion-${var.environment}"
  zone         = "${var.region}-a"
  
  machine_type = "e2-micro"
  image_family = "ubuntu-2204-lts"
  image_project = "ubuntu-os-cloud"
  
  # Network configuration
  network    = module.vpc.network_name
  subnetwork = "${var.project_name}-mgmt-subnet-${var.environment}"
  
  # Static internal IP
  internal_ip = var.bastion_internal_ip
  
  # Enable IP forwarding for NAT functionality
  can_ip_forward = true
  
  # Attach external IP for SSH access
  access_configs = [{
    nat_ip = null  # Ephemeral IP
  }]

  # Startup script for bastion configuration
  startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y kubectl google-cloud-sdk-gke-gcloud-auth-plugin
    
    # Configure kubectl for the GKE cluster
    gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}
    
    # Install Cloud SQL proxy
    curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.0/cloud-sql-proxy.linux.amd64
    chmod +x cloud-sql-proxy
    mv cloud-sql-proxy /usr/local/bin/
  EOF

  # Service account
  service_account_email = "${local.service_accounts.gke_cluster}@${var.project_id}.iam.gserviceaccount.com"
  service_account_scopes = [
    "https://www.googleapis.com/auth/cloud-platform"
  ]

  # Tags for firewall rules
  tags = ["ssh-access", "bastion"]

  labels = merge(local.common_labels, {
    role = "bastion"
  })

  depends_on = [
    module.vpc,
    module.iam,
    module.gke
  ]
}