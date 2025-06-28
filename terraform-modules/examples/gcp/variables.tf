# GCP Microservices Platform - Variables

# Project Configuration
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "microservices-platform"
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_name))
    error_message = "Project name must start with a letter, contain only lowercase letters, numbers, and hyphens, and end with a letter or number."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "replica_region" {
  description = "GCP region for read replicas and cross-region resources"
  type        = string
  default     = "us-east1"
}

# Domain Configuration
variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "example.com"
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "gke_subnet_cidr" {
  description = "CIDR block for GKE subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "gke_pods_cidr" {
  description = "CIDR block for GKE pods secondary range"
  type        = string
  default     = "10.1.0.0/16"
}

variable "gke_services_cidr" {
  description = "CIDR block for GKE services secondary range"
  type        = string
  default     = "10.2.0.0/16"
}

variable "gke_master_cidr" {
  description = "CIDR block for GKE master nodes"
  type        = string
  default     = "10.3.0.0/28"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet (databases)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "mgmt_subnet_cidr" {
  description = "CIDR block for management subnet (bastion, monitoring)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "authorized_networks_cidr" {
  description = "CIDR block for authorized networks to access GKE master"
  type        = string
  default     = "0.0.0.0/0"
  
  validation {
    condition     = can(cidrhost(var.authorized_networks_cidr, 0))
    error_message = "Authorized networks CIDR must be a valid CIDR block."
  }
}

# GKE Configuration
variable "gke_node_count" {
  description = "Initial number of nodes in the GKE node pool"
  type        = number
  default     = 2
  
  validation {
    condition     = var.gke_node_count >= 1 && var.gke_node_count <= 10
    error_message = "GKE node count must be between 1 and 10."
  }
}

variable "gke_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-4"
  
  validation {
    condition = contains([
      "e2-standard-2", "e2-standard-4", "e2-standard-8", "e2-standard-16",
      "n1-standard-2", "n1-standard-4", "n1-standard-8", "n1-standard-16",
      "n2-standard-2", "n2-standard-4", "n2-standard-8", "n2-standard-16"
    ], var.gke_machine_type)
    error_message = "GKE machine type must be a valid standard machine type."
  }
}

variable "gke_high_memory_machine_type" {
  description = "Machine type for high-memory GKE nodes"
  type        = string
  default     = "n2-highmem-4"
  
  validation {
    condition = contains([
      "n1-highmem-2", "n1-highmem-4", "n1-highmem-8", "n1-highmem-16",
      "n2-highmem-2", "n2-highmem-4", "n2-highmem-8", "n2-highmem-16"
    ], var.gke_high_memory_machine_type)
    error_message = "GKE high-memory machine type must be a valid high-memory machine type."
  }
}

# Cloud SQL Configuration
variable "cloudsql_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-custom-2-8192"  # 2 vCPU, 8GB RAM
  
  validation {
    condition = can(regex("^db-(custom|standard|shared-core|n1|f1)-", var.cloudsql_tier))
    error_message = "Cloud SQL tier must be a valid tier format."
  }
}

variable "cloudsql_replica_tier" {
  description = "Cloud SQL read replica instance tier"
  type        = string
  default     = "db-custom-1-4096"  # 1 vCPU, 4GB RAM
}

variable "cloudsql_disk_size" {
  description = "Cloud SQL disk size in GB"
  type        = number
  default     = 100
  
  validation {
    condition     = var.cloudsql_disk_size >= 20 && var.cloudsql_disk_size <= 10000
    error_message = "Cloud SQL disk size must be between 20 and 10000 GB."
  }
}

# Database Credentials (should be passed via environment variables or secret management)
variable "db_backend_password" {
  description = "Password for the backend database user"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_backend_password) >= 12
    error_message = "Database password must be at least 12 characters long."
  }
}

variable "db_readonly_password" {
  description = "Password for the readonly database user"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_readonly_password) >= 12
    error_message = "Database password must be at least 12 characters long."
  }
}

# Bastion Host Configuration
variable "bastion_internal_ip" {
  description = "Internal IP address for the bastion host"
  type        = string
  default     = "10.0.3.10"
  
  validation {
    condition     = can(regex("^10\\.0\\.3\\.", var.bastion_internal_ip))
    error_message = "Bastion internal IP must be in the management subnet range."
  }
}

# Monitoring and Observability
variable "enable_monitoring" {
  description = "Enable comprehensive monitoring stack"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable centralized logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
  
  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 365
    error_message = "Log retention days must be between 1 and 365."
  }
}

# Security Configuration
variable "enable_binary_authorization" {
  description = "Enable Binary Authorization for container image security"
  type        = bool
  default     = false
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity for secure service account access"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable Kubernetes Network Policy for pod-to-pod communication control"
  type        = bool
  default     = true
}

variable "enable_private_cluster" {
  description = "Create a private GKE cluster"
  type        = bool
  default     = true
}

# Backup and Disaster Recovery
variable "backup_retention_days" {
  description = "Number of days to retain database backups"
  type        = number
  default     = 30
  
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 365
    error_message = "Backup retention days must be between 7 and 365."
  }
}

variable "enable_cross_region_backup" {
  description = "Enable cross-region backup for disaster recovery"
  type        = bool
  default     = false
}

# Cost Optimization
variable "enable_preemptible_nodes" {
  description = "Use preemptible nodes for cost optimization (not recommended for production)"
  type        = bool
  default     = true
}

variable "enable_cluster_autoscaling" {
  description = "Enable cluster autoscaling to optimize costs"
  type        = bool
  default     = true
}

variable "min_node_count" {
  description = "Minimum number of nodes in the cluster"
  type        = number
  default     = 1
  
  validation {
    condition     = var.min_node_count >= 1 && var.min_node_count <= 10
    error_message = "Minimum node count must be between 1 and 10."
  }
}

variable "max_node_count" {
  description = "Maximum number of nodes in the cluster"
  type        = number
  default     = 10
  
  validation {
    condition     = var.max_node_count >= 1 && var.max_node_count <= 100
    error_message = "Maximum node count must be between 1 and 100."
  }
}

# Feature Flags
variable "enable_istio" {
  description = "Enable Istio service mesh"
  type        = bool
  default     = false
}

variable "enable_cloud_run" {
  description = "Enable Cloud Run addon for serverless workloads"
  type        = bool
  default     = false
}

variable "enable_config_connector" {
  description = "Enable Config Connector for managing GCP resources via Kubernetes"
  type        = bool
  default     = false
}

# Resource Limits
variable "cpu_limit" {
  description = "Maximum CPU cores for cluster autoscaling"
  type        = number
  default     = 100
  
  validation {
    condition     = var.cpu_limit >= 4 && var.cpu_limit <= 1000
    error_message = "CPU limit must be between 4 and 1000."
  }
}

variable "memory_limit" {
  description = "Maximum memory in GB for cluster autoscaling"
  type        = number
  default     = 400
  
  validation {
    condition     = var.memory_limit >= 16 && var.memory_limit <= 4000
    error_message = "Memory limit must be between 16 and 4000 GB."
  }
}