# Shared Security Module - Outputs

# KMS/Encryption Information
output "kms_encryption_enabled" {
  description = "Whether KMS encryption is enabled"
  value       = var.enable_kms_encryption
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = var.cloud_provider == "aws" && var.enable_kms_encryption ? aws_kms_key.main[0].id : null
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = var.cloud_provider == "aws" && var.enable_kms_encryption ? aws_kms_key.main[0].arn : null
}

output "kms_key_alias" {
  description = "KMS key alias"
  value       = var.cloud_provider == "aws" && var.enable_kms_encryption ? aws_kms_alias.main[0].name : null
}

output "azure_key_vault_id" {
  description = "Azure Key Vault ID"
  value       = var.cloud_provider == "azure" && var.enable_key_vault ? azurerm_key_vault.main[0].id : null
}

output "azure_key_vault_uri" {
  description = "Azure Key Vault URI"
  value       = var.cloud_provider == "azure" && var.enable_key_vault ? azurerm_key_vault.main[0].vault_uri : null
}

output "gcp_kms_key_ring_id" {
  description = "GCP KMS key ring ID"
  value       = var.cloud_provider == "gcp" && var.enable_gcp_kms ? google_kms_key_ring.main[0].id : null
}

output "gcp_kms_crypto_key_id" {
  description = "GCP KMS crypto key ID"
  value       = var.cloud_provider == "gcp" && var.enable_gcp_kms ? google_kms_crypto_key.main[0].id : null
}

# SSL Certificates Information
output "ssl_certificates" {
  description = "SSL certificates information"
  value = var.cloud_provider == "aws" ? {
    for name, cert in aws_acm_certificate.main : name => {
      arn           = cert.arn
      domain_name   = cert.domain_name
      status        = cert.status
      validation_method = cert.validation_method
    }
  } : {}
}

output "ssl_certificates_count" {
  description = "Number of SSL certificates"
  value       = length(var.ssl_certificates)
}

# IAM Information
output "iam_policies" {
  description = "IAM policies information"
  value = var.cloud_provider == "aws" ? {
    for name, policy in aws_iam_policy.security_policies : name => {
      arn  = policy.arn
      name = policy.name
    }
  } : {}
}

output "iam_roles" {
  description = "IAM roles information"
  value = var.cloud_provider == "aws" ? {
    for name, role in aws_iam_role.security_roles : name => {
      arn  = role.arn
      name = role.name
    }
  } : {}
}

output "iam_policies_count" {
  description = "Number of IAM policies"
  value       = length(var.iam_policies)
}

output "iam_roles_count" {
  description = "Number of IAM roles"
  value       = length(var.iam_roles)
}

# Security Groups Information
output "security_groups" {
  description = "Security groups information"
  value = var.cloud_provider == "aws" ? {
    for name, sg in aws_security_group.security_groups : name => {
      id   = sg.id
      arn  = sg.arn
      name = sg.name
    }
  } : {}
}

output "security_groups_count" {
  description = "Number of security groups"
  value       = length(var.security_groups)
}

# WAF Information
output "waf_web_acls" {
  description = "WAF Web ACLs information"
  value = var.cloud_provider == "aws" ? {
    for name, acl in aws_wafv2_web_acl.main : name => {
      id   = acl.id
      arn  = acl.arn
      name = acl.name
    }
  } : {}
}

output "waf_web_acls_count" {
  description = "Number of WAF Web ACLs"
  value       = length(var.waf_web_acls)
}

# AWS Config Information
output "aws_config_enabled" {
  description = "Whether AWS Config is enabled"
  value       = var.enable_aws_config
}

output "aws_config_recorder_name" {
  description = "AWS Config recorder name"
  value       = var.enable_aws_config ? var.aws_config_recorder_name : null
}

output "aws_config_rules" {
  description = "AWS Config rules information"
  value = var.cloud_provider == "aws" && var.enable_aws_config ? {
    for name, rule in aws_config_config_rule.security_rules : name => {
      name = rule.name
      arn  = rule.arn
    }
  } : {}
}

output "aws_config_rules_count" {
  description = "Number of AWS Config rules"
  value       = length(var.aws_config_rules)
}

# CloudTrail Information
output "cloudtrail_enabled" {
  description = "Whether CloudTrail is enabled"
  value       = var.enable_cloudtrail
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = var.cloud_provider == "aws" && var.enable_cloudtrail ? aws_cloudtrail.main[0].arn : null
}

output "cloudtrail_name" {
  description = "CloudTrail name"
  value       = var.enable_cloudtrail ? var.cloudtrail_name : null
}

# GuardDuty Information
output "guardduty_enabled" {
  description = "Whether GuardDuty is enabled"
  value       = var.enable_guardduty
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = var.cloud_provider == "aws" && var.enable_guardduty ? aws_guardduty_detector.main[0].id : null
}

# Security Hub Information
output "security_hub_enabled" {
  description = "Whether Security Hub is enabled"
  value       = var.enable_security_hub
}

output "security_hub_standards" {
  description = "Enabled Security Hub standards"
  value       = var.enable_security_hub ? var.security_hub_standards : []
}

output "security_hub_standards_count" {
  description = "Number of enabled Security Hub standards"
  value       = var.enable_security_hub ? length(var.security_hub_standards) : 0
}

# Secrets Manager Information
output "secrets_manager_secrets" {
  description = "Secrets Manager secrets information"
  value = var.cloud_provider == "aws" ? {
    for name, secret in aws_secretsmanager_secret.secrets : name => {
      arn  = secret.arn
      name = secret.name
    }
  } : {}
  sensitive = true
}

output "secrets_manager_secrets_count" {
  description = "Number of Secrets Manager secrets"
  value       = length(var.secrets_manager_secrets)
}

# Generated Passwords Information
output "generated_vault_unseal_key" {
  description = "Generated Vault unseal key"
  value       = var.generate_vault_unseal_key ? random_password.vault_unseal_key[0].result : null
  sensitive   = true
}

output "generated_database_passwords" {
  description = "Generated database passwords"
  value = {
    for key, password in random_password.database_passwords : key => password.result
  }
  sensitive = true
}

output "generated_passwords_count" {
  description = "Number of generated passwords"
  value       = length(var.generate_database_passwords)
}

# Security Summary
output "security_services_summary" {
  description = "Summary of enabled security services"
  value = {
    cloud_provider      = var.cloud_provider
    kms_encryption      = var.enable_kms_encryption
    cloudtrail         = var.enable_cloudtrail
    guardduty          = var.enable_guardduty
    security_hub       = var.enable_security_hub
    aws_config         = var.enable_aws_config
    key_vault          = var.enable_key_vault
    gcp_kms           = var.enable_gcp_kms
  }
}

output "security_resources_count" {
  description = "Count of security resources by type"
  value = {
    ssl_certificates    = length(var.ssl_certificates)
    iam_policies       = length(var.iam_policies)
    iam_roles          = length(var.iam_roles)
    security_groups    = length(var.security_groups)
    waf_web_acls       = length(var.waf_web_acls)
    config_rules       = length(var.aws_config_rules)
    secrets            = length(var.secrets_manager_secrets)
    total_resources    = length(var.ssl_certificates) + length(var.iam_policies) + 
                        length(var.iam_roles) + length(var.security_groups) + 
                        length(var.waf_web_acls) + length(var.aws_config_rules) + 
                        length(var.secrets_manager_secrets)
  }
}

# Compliance Information
output "compliance_standards" {
  description = "Configured compliance standards"
  value       = var.compliance_standards
}

output "compliance_standards_count" {
  description = "Number of compliance standards"
  value       = length(var.compliance_standards)
}

# Security Monitoring Information
output "security_monitoring_enabled" {
  description = "Whether security monitoring is enabled"
  value       = var.enable_security_monitoring
}

output "security_monitoring_config" {
  description = "Security monitoring configuration"
  value       = var.security_monitoring_config
}

# Backup Configuration
output "backup_configuration" {
  description = "Backup configuration for security resources"
  value       = var.backup_configuration
}

# Incident Response Configuration
output "incident_response_enabled" {
  description = "Whether incident response is enabled"
  value       = var.incident_response_config.enable_incident_response
}

output "incident_response_config" {
  description = "Incident response configuration"
  value       = var.incident_response_config
  sensitive   = true
}

# Threat Intelligence Configuration
output "threat_intelligence_enabled" {
  description = "Whether threat intelligence is enabled"
  value       = var.threat_intelligence_config.enable_threat_intelligence
}

output "threat_intelligence_config" {
  description = "Threat intelligence configuration"
  value       = var.threat_intelligence_config
}

# Zero Trust Configuration
output "zero_trust_enabled" {
  description = "Whether Zero Trust is enabled"
  value       = var.zero_trust_config.enable_zero_trust
}

output "zero_trust_config" {
  description = "Zero Trust configuration"
  value       = var.zero_trust_config
}

# Security Architecture Information
output "security_architecture" {
  description = "Security architecture summary"
  value = {
    cloud_provider              = var.cloud_provider
    encryption_at_rest          = var.enable_kms_encryption
    audit_logging              = var.enable_cloudtrail
    threat_detection           = var.enable_guardduty
    security_hub_centralization = var.enable_security_hub
    compliance_monitoring      = var.enable_aws_config
    certificate_management     = length(var.ssl_certificates) > 0
    secrets_management         = length(var.secrets_manager_secrets) > 0
    network_security           = length(var.security_groups) > 0
    web_application_firewall   = length(var.waf_web_acls) > 0
    identity_access_management = length(var.iam_policies) > 0 || length(var.iam_roles) > 0
    security_monitoring        = var.enable_security_monitoring
    incident_response          = var.incident_response_config.enable_incident_response
    threat_intelligence        = var.threat_intelligence_config.enable_threat_intelligence
    zero_trust_architecture    = var.zero_trust_config.enable_zero_trust
  }
}

# Cost Estimation
output "estimated_monthly_costs" {
  description = "Estimated monthly costs for security services (USD)"
  value = {
    kms_keys           = var.enable_kms_encryption ? 1 : 0  # $1 per key per month
    cloudtrail         = var.enable_cloudtrail ? 2 : 0     # ~$2 per trail per month
    guardduty          = var.enable_guardduty ? 30 : 0     # ~$30 per month base
    security_hub       = var.enable_security_hub ? 30 : 0  # ~$30 per month
    config             = var.enable_aws_config ? 20 : 0    # ~$20 per month
    secrets_manager    = length(var.secrets_manager_secrets) * 0.40  # $0.40 per secret per month
    waf                = length(var.waf_web_acls) * 5      # ~$5 per Web ACL per month
    acm_certificates   = 0  # Free for AWS services
    total_base_cost    = (var.enable_kms_encryption ? 1 : 0) +
                        (var.enable_cloudtrail ? 2 : 0) +
                        (var.enable_guardduty ? 30 : 0) +
                        (var.enable_security_hub ? 30 : 0) +
                        (var.enable_aws_config ? 20 : 0) +
                        (length(var.secrets_manager_secrets) * 0.40) +
                        (length(var.waf_web_acls) * 5)
    note = "Estimates exclude data processing charges and may vary by region and usage"
  }
}

# Validation Results
output "validation_results" {
  description = "Security validation results"
  value = {
    security_baseline_validation = var.validate_security_baseline
    security_report_generated    = var.generate_security_report
  }
}

# Generated Files
output "generated_files" {
  description = "List of generated security documentation files"
  value = compact([
    var.generate_security_report ? "security-compliance-report.md" : "",
    var.validate_security_baseline ? "security-baseline-validation.json" : ""
  ])
}

# Common Tags
output "common_tags" {
  description = "Common tags applied to resources"
  value       = local.common_tags
}