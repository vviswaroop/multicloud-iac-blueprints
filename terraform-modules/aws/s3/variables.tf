variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "encryption_enabled" {
  description = "Enable server-side encryption for the S3 bucket"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (if not provided, uses S3 managed key)"
  type        = string
  default     = ""
}

variable "public_access_block" {
  description = "S3 bucket public access block configuration"
  type = object({
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  })
  default = {}
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type = list(object({
    id     = string
    status = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    expiration = optional(object({
      days = number
    }))
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }))
    transition = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = []
}

variable "cors_rules" {
  description = "List of CORS rules"
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "website_configuration" {
  description = "Website configuration"
  type = object({
    index_document = optional(string)
    error_document = optional(string)
    redirect_all_requests_to = optional(object({
      host_name = string
      protocol  = optional(string)
    }))
  })
  default = null
}

variable "notification_configuration" {
  description = "S3 bucket notification configuration"
  type = object({
    lambda_functions = optional(list(object({
      lambda_function_arn = string
      events              = list(string)
      filter_prefix       = optional(string)
      filter_suffix       = optional(string)
    })), [])
    sns_topics = optional(list(object({
      topic_arn     = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })), [])
    sqs_queues = optional(list(object({
      queue_arn     = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })), [])
  })
  default = null
}

variable "logging_configuration" {
  description = "S3 bucket logging configuration"
  type = object({
    target_bucket = string
    target_prefix = optional(string)
  })
  default = null
}

variable "replication_configuration" {
  description = "S3 bucket replication configuration"
  type = object({
    role = string
    rules = list(object({
      id     = string
      status = string
      filter = optional(object({
        prefix = optional(string)
        tags   = optional(map(string))
      }))
      destination = object({
        bucket        = string
        storage_class = optional(string)
      })
    }))
  })
  default = null
}

variable "force_destroy" {
  description = "Allow deletion of non-empty bucket"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}