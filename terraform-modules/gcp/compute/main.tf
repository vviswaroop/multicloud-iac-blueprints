resource "google_compute_instance" "main" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  tags = var.tags
  labels = var.labels

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size_gb
      type  = var.disk_type
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork != "" ? var.subnetwork : null

    dynamic "access_config" {
      for_each = var.external_ip ? [1] : []
      content {
        // Ephemeral public IP
      }
    }
  }

  metadata = merge(
    var.metadata,
    var.startup_script != "" ? {
      startup-script = var.startup_script
    } : {}
  )

  dynamic "service_account" {
    for_each = var.service_account != null ? [var.service_account] : []
    content {
      email  = service_account.value.email
      scopes = service_account.value.scopes
    }
  }
}