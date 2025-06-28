variable "role_assignments" {
  description = "List of role assignments"
  type = list(object({
    principal_id         = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
    scope               = string
    condition           = optional(string)
    condition_version   = optional(string)
  }))
  default = []
}

variable "custom_roles" {
  description = "Map of custom role definitions"
  type = map(object({
    name        = string
    description = optional(string, "")
    scope       = string
    permissions = list(object({
      actions          = optional(list(string), [])
      not_actions      = optional(list(string), [])
      data_actions     = optional(list(string), [])
      not_data_actions = optional(list(string), [])
    }))
    assignable_scopes = optional(list(string), [])
  }))
  default = {}
}

variable "service_principals" {
  description = "Map of service principal configurations"
  type = map(object({
    display_name = string
    description  = optional(string, "")
    owners       = optional(list(string), [])
    
    password = optional(object({
      display_name = optional(string, "")
      end_date     = optional(string)
    }))
    
    certificate = optional(object({
      display_name = optional(string, "")
      end_date     = optional(string)
      key_id       = optional(string)
      type         = optional(string, "AsymmetricX509Cert")
      usage        = optional(string, "Verify")
      value        = string
    }))
  }))
  default = {}
}

variable "groups" {
  description = "Map of Azure AD group configurations"
  type = map(object({
    display_name     = string
    description      = optional(string, "")
    security_enabled = optional(bool, true)
    mail_enabled     = optional(bool, false)
    mail_nickname    = optional(string)
    owners           = optional(list(string), [])
    members          = optional(list(string), [])
  }))
  default = {}
}

variable "applications" {
  description = "Map of Azure AD application configurations"
  type = map(object({
    display_name = string
    description  = optional(string, "")
    owners       = optional(list(string), [])
    
    web = optional(object({
      homepage_url  = optional(string)
      logout_url    = optional(string)
      redirect_uris = optional(list(string), [])
    }))
    
    api = optional(object({
      mapped_claims_enabled          = optional(bool, false)
      requested_access_token_version = optional(number, 1)
    }))
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}