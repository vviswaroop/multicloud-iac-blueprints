# Shared Security Module - Variables

# Cloud Provider Configuration
variable "cloud_provider" {
  description = "Cloud provider (aws, azure, gcp)"
  type        = string
  default     = "aws"
  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be one of: aws, azure, gcp."
  }
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
  default     = ""
}

# Azure specific variables
variable "azure_location" {
  description = "Azure location for resources"
  type        = string
  default     = ""
}

variable "azure_resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = ""
}

# KMS/Key Management Configuration
variable "enable_kms_encryption" {
  description = "Enable KMS encryption"
  type        = bool
  default     = true
}

variable "kms_key_description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for encryption"
}

variable "kms_key_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 7
  validation {
    condition     = var.kms_key_deletion_window >= 7 && var.kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "kms_enable_key_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
}

variable "kms_key_policy" {
  description = "KMS key policy JSON"
  type        = string
  default     = null
}

variable "kms_key_alias" {
  description = "KMS key alias"
  type        = string
  default     = "security-module-key"
}

variable "kms_key_tags" {
  description = "Tags for KMS key"
  type        = map(string)
  default     = {}
}

# Azure Key Vault Configuration
variable "enable_key_vault" {
  description = "Enable Azure Key Vault"
  type        = bool
  default     = false
}

variable "azure_key_vault_name" {
  description = "Name for Azure Key Vault"
  type        = string
  default     = ""
}

variable "azure_key_vault_sku" {
  description = "SKU for Azure Key Vault"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.azure_key_vault_sku)
    error_message = "Azure Key Vault SKU must be either standard or premium."
  }
}

variable "azure_kv_enabled_for_deployment" {
  description = "Enable Azure Key Vault for deployment"
  type        = bool
  default     = false
}

variable "azure_kv_enabled_for_disk_encryption" {
  description = "Enable Azure Key Vault for disk encryption"
  type        = bool
  default     = true
}

variable "azure_kv_enabled_for_template_deployment" {
  description = "Enable Azure Key Vault for template deployment"
  type        = bool
  default     = false
}

variable "azure_kv_purge_protection_enabled" {
  description = "Enable purge protection for Azure Key Vault"
  type        = bool
  default     = true
}

variable "azure_kv_soft_delete_retention_days" {
  description = "Soft delete retention days for Azure Key Vault"
  type        = number
  default     = 90
  validation {
    condition     = var.azure_kv_soft_delete_retention_days >= 7 && var.azure_kv_soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90."
  }
}

variable "azure_kv_network_acls" {
  description = "Network ACLs for Azure Key Vault"
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "azure_key_vault_tags" {
  description = "Tags for Azure Key Vault"
  type        = map(string)
  default     = {}
}

# GCP KMS Configuration
variable "enable_gcp_kms" {
  description = "Enable GCP KMS"
  type        = bool
  default     = false
}

variable "gcp_kms_key_ring_name" {
  description = "Name for GCP KMS key ring"
  type        = string
  default     = "security-key-ring"
}

variable "gcp_kms_location" {
  description = "Location for GCP KMS key ring"
  type        = string
  default     = "global"
}

variable "gcp_kms_crypto_key_name" {
  description = "Name for GCP KMS crypto key"
  type        = string
  default     = "security-crypto-key"
}

variable "gcp_kms_rotation_period" {
  description = "Rotation period for GCP KMS crypto key"
  type        = string
  default     = "7776000s" # 90 days
}

variable "gcp_kms_crypto_key_version_template" {
  description = "Version template for GCP KMS crypto key"
  type = object({
    algorithm        = string
    protection_level = string
  })
  default = null
}

variable "gcp_kms_crypto_key_labels" {
  description = "Labels for GCP KMS crypto key"
  type        = map(string)
  default     = {}
}

# SSL Certificates Configuration
variable "ssl_certificates" {
  description = "SSL certificates configuration"
  type = map(object({
    domain_name                              = string
    subject_alternative_names                = optional(list(string), [])
    validation_method                        = optional(string, "DNS")
    certificate_transparency_logging_preference = optional(string, "ENABLED")
    tags                                     = optional(map(string), {})
  }))
  default = {}
}

# IAM Configuration
variable "iam_policies" {
  description = "IAM policies configuration"
  type = map(object({
    name            = string
    description     = string
    policy_document = string
    tags            = optional(map(string), {})
  }))
  default = {}
}

variable "iam_roles" {
  description = "IAM roles configuration"
  type = map(object({
    name                 = string
    description          = string
    assume_role_policy   = string
    max_session_duration = optional(number, 3600)
    managed_policy_arns  = optional(list(string), [])
    inline_policies = optional(list(object({
      name   = string
      policy = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# Security Groups Configuration
variable "security_groups" {
  description = "Security groups configuration"
  type = map(object({
    name        = string
    description = string
    vpc_id      = string
    ingress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
      self            = optional(bool, false)
      description     = optional(string, "")
    }))
    egress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
      self            = optional(bool, false)
      description     = optional(string, "")
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

# WAF Configuration
variable "waf_web_acls" {
  description = "WAF Web ACLs configuration"
  type = map(object({
    name           = string
    scope          = string
    default_action = string
    rules = list(object({
      name     = string
      priority = number
      action   = string
      statement_type = string
      statement = any
      cloudwatch_metrics_enabled = optional(bool, true)
      metric_name               = string
      sampled_requests_enabled  = optional(bool, true)
    }))
    cloudwatch_metrics_enabled = optional(bool, true)
    metric_name               = string
    sampled_requests_enabled  = optional(bool, true)
    tags                      = optional(map(string), {})
  }))
  default = {}
}

# AWS Config Configuration
variable "enable_aws_config" {
  description = "Enable AWS Config"
  type        = bool
  default     = false
}

variable "aws_config_recorder_name" {
  description = "Name for AWS Config recorder"
  type        = string
  default     = "security-config-recorder"
}

variable "aws_config_delivery_channel_name" {
  description = "Name for AWS Config delivery channel"
  type        = string
  default     = "security-config-delivery-channel"
}

variable "aws_config_s3_bucket_name" {
  description = "S3 bucket name for AWS Config"
  type        = string
  default     = ""
}

variable "aws_config_all_supported" {
  description = "Record all supported resource types"
  type        = bool
  default     = true
}

variable "aws_config_include_global_resource_types" {
  description = "Include global resource types"
  type        = bool
  default     = true
}

variable "aws_config_rules" {
  description = "AWS Config rules"
  type = map(object({
    name                      = string
    source_owner              = string
    source_identifier         = string
    scope = optional(object({
      compliance_resource_types = list(string)
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

# CloudTrail Configuration
variable "enable_cloudtrail" {
  description = "Enable CloudTrail"
  type        = bool
  default     = false
}

variable "cloudtrail_name" {
  description = "Name for CloudTrail"
  type        = string
  default     = "security-cloudtrail"
}

variable "cloudtrail_s3_bucket_name" {
  description = "S3 bucket name for CloudTrail"
  type        = string
  default     = ""
}

variable "cloudtrail_kms_key_id" {
  description = "KMS key ID for CloudTrail encryption"
  type        = string
  default     = null
}

variable "cloudtrail_read_write_type" {
  description = "CloudTrail read/write type"
  type        = string
  default     = "All"
  validation {
    condition     = contains(["ReadOnly", "WriteOnly", "All"], var.cloudtrail_read_write_type)
    error_message = "CloudTrail read/write type must be ReadOnly, WriteOnly, or All."
  }
}

variable "cloudtrail_include_management_events" {
  description = "Include management events in CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_exclude_management_event_sources" {
  description = "Exclude management event sources"
  type        = list(string)
  default     = []
}

variable "cloudtrail_data_resources" {
  description = "CloudTrail data resources"
  type = list(object({
    type   = string
    values = list(string)
  }))
  default = []
}

variable "cloudtrail_enable_logging" {
  description = "Enable CloudTrail logging"
  type        = bool
  default     = true
}

variable "cloudtrail_enable_log_file_validation" {
  description = "Enable CloudTrail log file validation"
  type        = bool
  default     = true
}

variable "cloudtrail_include_global_service_events" {
  description = "Include global service events"
  type        = bool
  default     = true
}

variable "cloudtrail_is_multi_region_trail" {
  description = "Is multi-region trail"
  type        = bool
  default     = true
}

variable "cloudtrail_is_organization_trail" {
  description = "Is organization trail"
  type        = bool
  default     = false
}

variable "cloudtrail_tags" {
  description = "Tags for CloudTrail"
  type        = map(string)
  default     = {}
}

# GuardDuty Configuration
variable "enable_guardduty" {
  description = "Enable GuardDuty"
  type        = bool
  default     = false
}

variable "guardduty_s3_logs_enabled" {
  description = "Enable S3 logs in GuardDuty"
  type        = bool
  default     = true
}

variable "guardduty_kubernetes_audit_logs_enabled" {
  description = "Enable Kubernetes audit logs in GuardDuty"
  type        = bool
  default     = true
}

variable "guardduty_malware_protection_enabled" {
  description = "Enable malware protection in GuardDuty"
  type        = bool
  default     = true
}

variable "guardduty_finding_publishing_frequency" {
  description = "GuardDuty finding publishing frequency"
  type        = string
  default     = "SIX_HOURS"
  validation {
    condition = contains([
      "FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"
    ], var.guardduty_finding_publishing_frequency)
    error_message = "GuardDuty finding publishing frequency must be FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "guardduty_tags" {
  description = "Tags for GuardDuty"
  type        = map(string)
  default     = {}
}

# Security Hub Configuration
variable "enable_security_hub" {
  description = "Enable Security Hub"
  type        = bool
  default     = false
}

variable "security_hub_enable_default_standards" {
  description = "Enable default standards in Security Hub"
  type        = bool
  default     = true
}

variable "security_hub_standards" {
  description = "Security Hub standards to enable"
  type        = list(string)
  default = [
    "arn:aws:securityhub:::ruleset/finding-format/aws-foundational-security-standard/v/1.0.0",
    "arn:aws:securityhub:::ruleset/finding-format/cis-aws-foundations-benchmark/v/1.2.0"
  ]
}

# Secrets Manager Configuration
variable "secrets_manager_secrets" {
  description = "Secrets Manager secrets configuration"
  type = map(object({
    name                    = string
    description             = string
    kms_key_id             = optional(string)
    recovery_window_in_days = optional(number, 30)
    secret_string          = optional(string)
    secret_key_value       = optional(map(string), {})
    replica_regions = optional(list(object({
      region     = string
      kms_key_id = optional(string)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# Password Generation Configuration
variable "generate_vault_unseal_key" {
  description = "Generate Vault unseal key"
  type        = bool
  default     = false
}

variable "generate_database_passwords" {
  description = "Generate database passwords for secrets"
  type        = set(string)
  default     = []
}

variable "database_password_length" {
  description = "Length of generated database passwords"
  type        = number
  default     = 32
  validation {
    condition     = var.database_password_length >= 12 && var.database_password_length <= 128
    error_message = "Database password length must be between 12 and 128 characters."
  }
}

# Compliance Configuration
variable "compliance_standards" {
  description = "Compliance standards to implement"
  type        = list(string)
  default     = ["cis", "nist", "pci-dss"]
  validation {
    condition = alltrue([
      for standard in var.compliance_standards :
      contains(["cis", "nist", "pci-dss", "hipaa", "sox", "gdpr"], standard)
    ])
    error_message = "Compliance standard must be one of: cis, nist, pci-dss, hipaa, sox, gdpr."
  }
}

variable "validate_security_baseline" {
  description = "Validate security baseline configuration"
  type        = bool
  default     = true
}

variable "generate_security_report" {
  description = "Generate security compliance report"
  type        = bool
  default     = false
}

# Tagging Configuration
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Security Monitoring Configuration
variable "enable_security_monitoring" {
  description = "Enable security monitoring and alerting"
  type        = bool
  default     = false
}

variable "security_monitoring_config" {
  description = "Security monitoring configuration"
  type = object({
    enable_cloudwatch_insights = optional(bool, true)
    enable_eventbridge_rules   = optional(bool, true)
    sns_topic_arn             = optional(string)
    slack_webhook_url         = optional(string)
    alert_thresholds = optional(object({
      failed_logins_threshold    = optional(number, 5)
      privilege_escalation_alert = optional(bool, true)
      data_exfiltration_alert   = optional(bool, true)
      suspicious_api_calls      = optional(bool, true)
    }), {})
  })
  default = {}
}

# Backup and Recovery Configuration
variable "backup_configuration" {
  description = "Backup configuration for security resources"
  type = object({
    enable_backup         = optional(bool, false)
    backup_vault_name     = optional(string, "security-backup-vault")
    backup_plan_name      = optional(string, "security-backup-plan")
    backup_schedule       = optional(string, "cron(0 2 ? * * *)")
    backup_retention_days = optional(number, 30)
    cross_region_backup   = optional(bool, false)
    backup_region         = optional(string)
  })
  default = {}
}

# Incident Response Configuration
variable "incident_response_config" {
  description = "Incident response configuration"
  type = object({
    enable_incident_response = optional(bool, false)
    response_team_emails     = optional(list(string), [])
    escalation_sns_topic     = optional(string)
    playbook_s3_bucket      = optional(string)
    automated_response_enabled = optional(bool, false)
    quarantine_actions = optional(object({
      isolate_compromised_instances = optional(bool, true)
      disable_compromised_users     = optional(bool, true)
      snapshot_affected_volumes     = optional(bool, true)
    }), {})
  })
  default = {}
}

# Threat Intelligence Configuration
variable "threat_intelligence_config" {
  description = "Threat intelligence configuration"
  type = object({
    enable_threat_intelligence = optional(bool, false)
    threat_intel_feeds        = optional(list(string), [])
    custom_indicators         = optional(list(string), [])
    intel_sharing_enabled     = optional(bool, false)
  })
  default = {}
}

# Zero Trust Configuration
variable "zero_trust_config" {
  description = "Zero Trust architecture configuration"
  type = object({
    enable_zero_trust        = optional(bool, false)
    device_compliance_required = optional(bool, true)
    continuous_verification   = optional(bool, true)
    micro_segmentation       = optional(bool, true)
    least_privilege_access   = optional(bool, true)
  })
  default = {}
}