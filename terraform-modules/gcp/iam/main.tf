resource "google_service_account" "service_accounts" {
  for_each = var.service_accounts

  account_id   = each.key
  display_name = each.value.display_name
  description  = each.value.description
  project      = var.project_id
  disabled     = each.value.disabled
}

resource "google_service_account_key" "keys" {
  for_each = var.service_account_keys

  service_account_id = google_service_account.service_accounts[each.value.service_account_id].name
  key_algorithm      = each.value.key_algorithm
  private_key_type   = each.value.private_key_type
  public_key_type    = each.value.public_key_type
}

resource "google_project_iam_binding" "project_bindings" {
  for_each = var.project_iam_bindings

  project = var.project_id
  role    = each.key
  members = each.value.members

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_project_iam_member" "project_members" {
  for_each = var.project_iam_members

  project = var.project_id
  role    = each.value.role
  member  = each.value.member

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_service_account_iam_binding" "sa_bindings" {
  for_each = var.service_account_iam_bindings

  service_account_id = google_service_account.service_accounts[each.value.service_account_id].name
  role               = each.value.role
  members            = each.value.members

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_project_iam_custom_role" "custom_roles" {
  for_each = var.custom_roles

  role_id     = each.key
  title       = each.value.title
  description = each.value.description
  project     = var.project_id
  permissions = each.value.permissions
  stage       = each.value.stage
}

resource "google_organization_iam_binding" "org_bindings" {
  for_each = var.organization_iam_bindings

  org_id  = var.organization_id
  role    = each.key
  members = each.value.members

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_folder_iam_binding" "folder_bindings" {
  for_each = var.folder_iam_bindings

  folder  = each.value.folder
  role    = each.value.role
  members = each.value.members

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_project_iam_audit_config" "audit_configs" {
  for_each = var.audit_configs

  project = var.project_id
  service = each.key

  dynamic "audit_log_config" {
    for_each = each.value.audit_log_configs
    content {
      log_type         = audit_log_config.value.log_type
      exempted_members = audit_log_config.value.exempted_members
    }
  }
}

resource "google_iam_workload_identity_pool" "pools" {
  for_each = var.workload_identity_pools

  workload_identity_pool_id = each.key
  display_name              = each.value.display_name
  description               = each.value.description
  project                   = var.project_id
  disabled                  = each.value.disabled
}

resource "google_iam_workload_identity_pool_provider" "providers" {
  for_each = var.workload_identity_providers

  workload_identity_pool_id          = google_iam_workload_identity_pool.pools[each.value.pool_id].workload_identity_pool_id
  workload_identity_pool_provider_id = each.key
  display_name                       = each.value.display_name
  description                        = each.value.description
  project                            = var.project_id
  disabled                           = each.value.disabled

  attribute_mapping = each.value.attribute_mapping
  attribute_condition = each.value.attribute_condition

  dynamic "aws" {
    for_each = each.value.aws_config != null ? [each.value.aws_config] : []
    content {
      account_id = aws.value.account_id
    }
  }

  dynamic "oidc" {
    for_each = each.value.oidc_config != null ? [each.value.oidc_config] : []
    content {
      issuer_uri        = oidc.value.issuer_uri
      allowed_audiences = oidc.value.allowed_audiences
    }
  }
}