variable "bucket_name" {
  description = "Name of the GCS bucket"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Location of the bucket"
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "Storage class of the bucket"
  type        = string
  default     = "STANDARD"
  validation {
    condition = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "Storage class must be STANDARD, NEARLINE, COLDLINE, or ARCHIVE."
  }
}

variable "versioning_enabled" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "uniform_bucket_level_access" {
  description = "Enable uniform bucket level access"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow deletion of non-empty bucket"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type = list(object({
    condition = object({
      age                        = optional(number)
      created_before             = optional(string)
      with_state                 = optional(string)
      matches_storage_class      = optional(list(string))
      matches_prefix             = optional(list(string))
      matches_suffix             = optional(list(string))
      num_newer_versions         = optional(number)
      custom_time_before         = optional(string)
      days_since_custom_time     = optional(number)
      days_since_noncurrent_time = optional(number)
      noncurrent_time_before     = optional(string)
    })
    action = object({
      type          = string
      storage_class = optional(string)
    })
  }))
  default = []
}

variable "cors_rules" {
  description = "List of CORS rules"
  type = list(object({
    origin          = list(string)
    method          = list(string)
    response_header = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "website_configuration" {
  description = "Website configuration"
  type = object({
    main_page_suffix = optional(string)
    not_found_page   = optional(string)
  })
  default = null
}

variable "retention_policy" {
  description = "Retention policy configuration"
  type = object({
    is_locked        = bool
    retention_period = number
  })
  default = null
}

variable "kms_key_name" {
  description = "KMS key name for encryption"
  type        = string
  default     = null
}

variable "logging_config" {
  description = "Logging configuration"
  type = object({
    log_bucket        = string
    log_object_prefix = optional(string)
  })
  default = null
}

variable "iam_bindings" {
  description = "IAM role bindings for the bucket"
  type = map(object({
    members = list(string)
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = {}
}

variable "iam_members" {
  description = "IAM member bindings for the bucket"
  type = map(object({
    role   = string
    member = string
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = {}
}

variable "notification_configs" {
  description = "Notification configurations"
  type = map(object({
    payload_format    = string
    topic            = string
    event_types      = optional(list(string))
    object_name_prefix = optional(string)
    custom_attributes = optional(map(string))
  }))
  default = {}
}

variable "bucket_acl" {
  description = "Bucket ACL configuration"
  type = object({
    role_entity    = optional(list(string))
    predefined_acl = optional(string)
  })
  default = null
}

variable "labels" {
  description = "Labels to apply to the bucket"
  type        = map(string)
  default     = {}
}