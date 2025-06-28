resource "google_storage_bucket" "main" {
  name          = var.bucket_name
  location      = var.location
  project       = var.project_id
  storage_class = var.storage_class
  
  force_destroy = var.force_destroy

  uniform_bucket_level_access = var.uniform_bucket_level_access

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      condition {
        age                        = lifecycle_rule.value.condition.age
        created_before             = lifecycle_rule.value.condition.created_before
        with_state                 = lifecycle_rule.value.condition.with_state
        matches_storage_class      = lifecycle_rule.value.condition.matches_storage_class
        matches_prefix             = lifecycle_rule.value.condition.matches_prefix
        matches_suffix             = lifecycle_rule.value.condition.matches_suffix
        num_newer_versions         = lifecycle_rule.value.condition.num_newer_versions
        custom_time_before         = lifecycle_rule.value.condition.custom_time_before
        days_since_custom_time     = lifecycle_rule.value.condition.days_since_custom_time
        days_since_noncurrent_time = lifecycle_rule.value.condition.days_since_noncurrent_time
        noncurrent_time_before     = lifecycle_rule.value.condition.noncurrent_time_before
      }

      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lifecycle_rule.value.action.storage_class
      }
    }
  }

  dynamic "cors" {
    for_each = var.cors_rules
    content {
      origin          = cors.value.origin
      method          = cors.value.method
      response_header = cors.value.response_header
      max_age_seconds = cors.value.max_age_seconds
    }
  }

  dynamic "website" {
    for_each = var.website_configuration != null ? [var.website_configuration] : []
    content {
      main_page_suffix = website.value.main_page_suffix
      not_found_page   = website.value.not_found_page
    }
  }

  dynamic "retention_policy" {
    for_each = var.retention_policy != null ? [var.retention_policy] : []
    content {
      is_locked        = retention_policy.value.is_locked
      retention_period = retention_policy.value.retention_period
    }
  }

  dynamic "encryption" {
    for_each = var.kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = var.kms_key_name
    }
  }

  dynamic "logging" {
    for_each = var.logging_config != null ? [var.logging_config] : []
    content {
      log_bucket        = logging.value.log_bucket
      log_object_prefix = logging.value.log_object_prefix
    }
  }

  labels = var.labels
}

resource "google_storage_bucket_iam_binding" "bindings" {
  for_each = var.iam_bindings

  bucket = google_storage_bucket.main.name
  role   = each.key

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

resource "google_storage_bucket_iam_member" "members" {
  for_each = var.iam_members

  bucket = google_storage_bucket.main.name
  role   = each.value.role
  member = each.value.member

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_storage_notification" "notifications" {
  for_each = var.notification_configs

  bucket         = google_storage_bucket.main.name
  payload_format = each.value.payload_format
  topic          = each.value.topic
  event_types    = each.value.event_types
  
  dynamic "custom_attributes" {
    for_each = each.value.custom_attributes != null ? [each.value.custom_attributes] : []
    content {
      attribute_1 = custom_attributes.value.attribute_1
      attribute_2 = custom_attributes.value.attribute_2
    }
  }

  object_name_prefix = each.value.object_name_prefix
}

resource "google_storage_bucket_acl" "bucket_acl" {
  count = var.bucket_acl != null ? 1 : 0

  bucket = google_storage_bucket.main.name

  role_entity = var.bucket_acl.role_entity
  
  dynamic "predefined_acl" {
    for_each = var.bucket_acl.predefined_acl != null ? [var.bucket_acl.predefined_acl] : []
    content {
      predefined_acl = predefined_acl.value
    }
  }
}