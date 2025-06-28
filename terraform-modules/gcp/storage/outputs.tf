output "bucket_name" {
  description = "Name of the created bucket"
  value       = google_storage_bucket.main.name
}

output "bucket_url" {
  description = "URL of the created bucket"
  value       = google_storage_bucket.main.url
}

output "bucket_self_link" {
  description = "Self-link of the created bucket"
  value       = google_storage_bucket.main.self_link
}

output "bucket_location" {
  description = "Location of the created bucket"
  value       = google_storage_bucket.main.location
}

output "bucket_storage_class" {
  description = "Storage class of the created bucket"
  value       = google_storage_bucket.main.storage_class
}

output "bucket_project_number" {
  description = "Project number of the bucket"
  value       = google_storage_bucket.main.project_number
}

output "bucket_id" {
  description = "ID of the created bucket"
  value       = google_storage_bucket.main.id
}

output "versioning_enabled" {
  description = "Whether versioning is enabled"
  value       = var.versioning_enabled
}

output "uniform_bucket_level_access" {
  description = "Whether uniform bucket level access is enabled"
  value       = google_storage_bucket.main.uniform_bucket_level_access
}

output "iam_bindings" {
  description = "IAM bindings applied to the bucket"
  value       = var.iam_bindings
  sensitive   = true
}

output "notification_configs" {
  description = "Notification configurations for the bucket"
  value       = var.notification_configs
}