variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "organization_id" {
  description = "GCP organization ID (optional, required for organization-level IAM)"
  type        = string
  default     = null
}

variable "service_accounts" {
  description = "Map of service accounts to create"
  type = map(object({
    display_name = optional(string)
    description  = optional(string)
    disabled     = optional(bool, false)
  }))
  default = {}
}

variable "service_account_keys" {
  description = "Map of service account keys to create"
  type = map(object({
    service_account_id = string
    key_algorithm      = optional(string, "KEY_ALG_RSA_2048")
    private_key_type   = optional(string, "TYPE_GOOGLE_CREDENTIALS_FILE")
    public_key_type    = optional(string, "TYPE_X509_PEM_FILE")
  }))
  default = {}
}

variable "project_iam_bindings" {
  description = "IAM role bindings at the project level"
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

variable "project_iam_members" {
  description = "IAM member bindings at the project level"
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

variable "service_account_iam_bindings" {
  description = "IAM bindings for service accounts"
  type = map(object({
    service_account_id = string
    role               = string
    members            = list(string)
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = {}
}

variable "custom_roles" {
  description = "Custom IAM roles to create"
  type = map(object({
    title       = string
    description = optional(string)
    permissions = list(string)
    stage       = optional(string, "GA")
  }))
  default = {}
}

variable "organization_iam_bindings" {
  description = "IAM role bindings at the organization level"
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

variable "folder_iam_bindings" {
  description = "IAM role bindings at the folder level"
  type = map(object({
    folder  = string
    role    = string
    members = list(string)
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = {}
}

variable "audit_configs" {
  description = "Audit configuration for services"
  type = map(object({
    audit_log_configs = list(object({
      log_type         = string
      exempted_members = optional(list(string))
    }))
  }))
  default = {}
}

variable "workload_identity_pools" {
  description = "Workload Identity pools to create"
  type = map(object({
    display_name = optional(string)
    description  = optional(string)
    disabled     = optional(bool, false)
  }))
  default = {}
}

variable "workload_identity_providers" {
  description = "Workload Identity providers to create"
  type = map(object({
    pool_id             = string
    display_name        = optional(string)
    description         = optional(string)
    disabled            = optional(bool, false)
    attribute_mapping   = optional(map(string))
    attribute_condition = optional(string)
    aws_config = optional(object({
      account_id = string
    }))
    oidc_config = optional(object({
      issuer_uri        = string
      allowed_audiences = optional(list(string))
    }))
  }))
  default = {}
}