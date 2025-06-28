# GCP CloudSQL Module - Main Configuration

# Random password for the root user
resource "random_password" "root_password" {
  count   = var.generate_root_password ? 1 : 0
  length  = var.root_password_length
  special = true
}

# CloudSQL Instance
resource "google_sql_database_instance" "main" {
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  deletion_protection = var.deletion_protection

  settings {
    tier                        = var.tier
    availability_type          = var.availability_type
    disk_size                  = var.disk_size
    disk_type                  = var.disk_type
    disk_autoresize            = var.disk_autoresize
    disk_autoresize_limit      = var.disk_autoresize_limit
    user_labels                = var.user_labels

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      location                       = var.backup_location
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
      transaction_log_retention_days = var.transaction_log_retention_days
      backup_retention_settings {
        retained_backups = var.backup_retained_backups
        retention_unit   = var.backup_retention_unit
      }
    }

    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = var.maintenance_window_update_track
    }

    ip_configuration {
      ipv4_enabled                                  = var.ipv4_enabled
      private_network                               = var.private_network
      enable_private_path_for_google_cloud_services = var.enable_private_path_for_google_cloud_services
      allocated_ip_range                            = var.allocated_ip_range
      require_ssl                                   = var.require_ssl

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }

    insights_config {
      query_insights_enabled  = var.query_insights_enabled
      query_string_length     = var.query_string_length
      record_application_tags = var.record_application_tags
      record_client_address   = var.record_client_address
      query_plans_per_minute  = var.query_plans_per_minute
    }

    password_validation_policy {
      min_length                  = var.password_validation_min_length
      complexity                  = var.password_validation_complexity
      reuse_interval              = var.password_validation_reuse_interval
      disallow_username_substring = var.password_validation_disallow_username_substring
      enable_password_policy      = var.enable_password_validation_policy
    }
  }

  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }

  depends_on = [google_project_service.sqladmin]
}

# Enable Cloud SQL Admin API
resource "google_project_service" "sqladmin" {
  project = var.project_id
  service = "sqladmin.googleapis.com"

  disable_dependent_services = false
}

# Root user
resource "google_sql_user" "root" {
  count    = var.create_root_user ? 1 : 0
  name     = var.root_user_name
  instance = google_sql_database_instance.main.name
  type     = var.root_user_type
  password = var.generate_root_password ? random_password.root_password[0].result : var.root_user_password
  project  = var.project_id
}

# Additional databases
resource "google_sql_database" "additional_databases" {
  for_each = toset(var.additional_databases)
  
  name     = each.value
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# Additional users
resource "google_sql_user" "additional_users" {
  for_each = var.additional_users
  
  name     = each.key
  instance = google_sql_database_instance.main.name
  type     = each.value.type
  password = each.value.password
  project  = var.project_id

  dynamic "password_policy" {
    for_each = each.value.password_policy != null ? [each.value.password_policy] : []
    content {
      allowed_failed_attempts      = password_policy.value.allowed_failed_attempts
      password_expiration_duration = password_policy.value.password_expiration_duration
      enable_failed_attempts_check = password_policy.value.enable_failed_attempts_check
      enable_password_verification = password_policy.value.enable_password_verification
    }
  }
}

# Read replicas
resource "google_sql_database_instance" "read_replica" {
  for_each = var.read_replicas
  
  name                 = each.key
  master_instance_name = google_sql_database_instance.main.name
  region               = each.value.region
  database_version     = google_sql_database_instance.main.database_version
  project              = var.project_id

  replica_configuration {
    failover_target = each.value.failover_target
  }

  settings {
    tier                   = each.value.tier
    availability_type      = each.value.availability_type
    disk_size             = each.value.disk_size
    disk_type             = each.value.disk_type
    disk_autoresize       = each.value.disk_autoresize
    disk_autoresize_limit = each.value.disk_autoresize_limit
    user_labels           = merge(var.user_labels, each.value.user_labels)

    ip_configuration {
      ipv4_enabled    = each.value.ipv4_enabled
      private_network = each.value.private_network
      require_ssl     = each.value.require_ssl

      dynamic "authorized_networks" {
        for_each = each.value.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }

    backup_configuration {
      enabled = false
    }
  }

  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }
}

# SSL certificates
resource "google_sql_ssl_cert" "client_cert" {
  for_each = var.ssl_certificates
  
  common_name = each.key
  instance    = google_sql_database_instance.main.name
  project     = var.project_id
}