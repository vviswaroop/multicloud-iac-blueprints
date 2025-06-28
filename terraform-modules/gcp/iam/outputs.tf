output "service_accounts" {
  description = "Service accounts created"
  value = {
    for k, v in google_service_account.service_accounts : k => {
      name       = v.name
      email      = v.email
      unique_id  = v.unique_id
      account_id = v.account_id
    }
  }
}

output "service_account_keys" {
  description = "Service account keys created"
  value = {
    for k, v in google_service_account_key.keys : k => {
      name              = v.name
      key_algorithm     = v.key_algorithm
      private_key_type  = v.private_key_type
      public_key_type   = v.public_key_type
      public_key_data   = v.public_key_data
    }
  }
  sensitive = true
}

output "service_account_private_keys" {
  description = "Private keys for service accounts (base64 encoded)"
  value = {
    for k, v in google_service_account_key.keys : k => v.private_key
  }
  sensitive = true
}

output "custom_roles" {
  description = "Custom roles created"
  value = {
    for k, v in google_project_iam_custom_role.custom_roles : k => {
      name        = v.name
      role_id     = v.role_id
      title       = v.title
      description = v.description
      permissions = v.permissions
      stage       = v.stage
    }
  }
}

output "project_iam_bindings" {
  description = "Project-level IAM bindings"
  value       = var.project_iam_bindings
  sensitive   = true
}

output "workload_identity_pools" {
  description = "Workload Identity pools created"
  value = {
    for k, v in google_iam_workload_identity_pool.pools : k => {
      name                      = v.name
      workload_identity_pool_id = v.workload_identity_pool_id
      display_name              = v.display_name
      description               = v.description
      state                     = v.state
      disabled                  = v.disabled
    }
  }
}

output "workload_identity_providers" {
  description = "Workload Identity providers created"
  value = {
    for k, v in google_iam_workload_identity_pool_provider.providers : k => {
      name                               = v.name
      workload_identity_pool_provider_id = v.workload_identity_pool_provider_id
      display_name                       = v.display_name
      description                        = v.description
      state                              = v.state
      disabled                           = v.disabled
    }
  }
}

output "service_account_emails" {
  description = "Email addresses of created service accounts"
  value = {
    for k, v in google_service_account.service_accounts : k => v.email
  }
}

output "service_account_unique_ids" {
  description = "Unique IDs of created service accounts"
  value = {
    for k, v in google_service_account.service_accounts : k => v.unique_id
  }
}