variable "name" {
  description = "Name prefix for IAM resources"
  type        = string
}

variable "create_role" {
  description = "Whether to create an IAM role"
  type        = bool
  default     = true
}

variable "trusted_role_services" {
  description = "List of AWS services that can assume the role"
  type        = list(string)
  default     = []
}

variable "trusted_role_arns" {
  description = "List of ARNs that can assume the role"
  type        = list(string)
  default     = []
}

variable "custom_role_policy_arns" {
  description = "List of custom policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "aws_managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policies to attach to the role"
  type        = map(string)
  default     = {}
}

variable "create_instance_profile" {
  description = "Whether to create an instance profile"
  type        = bool
  default     = false
}

variable "create_user" {
  description = "Whether to create an IAM user"
  type        = bool
  default     = false
}

variable "create_group" {
  description = "Whether to create an IAM group"
  type        = bool
  default     = false
}

variable "group_users" {
  description = "List of users to add to the group"
  type        = list(string)
  default     = []
}

variable "create_access_key" {
  description = "Whether to create access keys for the user"
  type        = bool
  default     = false
}

variable "policy_documents" {
  description = "Map of policy documents to create as IAM policies"
  type        = map(string)
  default     = {}
}

variable "max_session_duration" {
  description = "Maximum session duration for the role"
  type        = number
  default     = 3600
}

variable "force_detach_policies" {
  description = "Whether to force detaching policies when destroying the role"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}