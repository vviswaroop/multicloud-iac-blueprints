# Shared Security Module - Main Configuration
# Security baselines and compliance rules

# Random passwords for various security components
resource "random_password" "vault_unseal_key" {
  count   = var.generate_vault_unseal_key ? 1 : 0
  length  = 32
  special = true
}

resource "random_password" "database_passwords" {
  for_each = var.generate_database_passwords
  length   = var.database_password_length
  special  = true
}

# KMS Key for encryption
resource "aws_kms_key" "main" {
  count = var.cloud_provider == "aws" && var.enable_kms_encryption ? 1 : 0

  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_enable_key_rotation
  
  policy = var.kms_key_policy != null ? var.kms_key_policy : jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current[0].account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, var.kms_key_tags)
}

resource "aws_kms_alias" "main" {
  count         = var.cloud_provider == "aws" && var.enable_kms_encryption ? 1 : 0
  name          = "alias/${var.kms_key_alias}"
  target_key_id = aws_kms_key.main[0].key_id
}

# Azure Key Vault
resource "azurerm_key_vault" "main" {
  count = var.cloud_provider == "azure" && var.enable_key_vault ? 1 : 0

  name                = var.azure_key_vault_name
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
  tenant_id           = data.azurerm_client_config.current[0].tenant_id
  sku_name            = var.azure_key_vault_sku

  enabled_for_deployment          = var.azure_kv_enabled_for_deployment
  enabled_for_disk_encryption     = var.azure_kv_enabled_for_disk_encryption
  enabled_for_template_deployment = var.azure_kv_enabled_for_template_deployment
  purge_protection_enabled        = var.azure_kv_purge_protection_enabled
  soft_delete_retention_days      = var.azure_kv_soft_delete_retention_days

  dynamic "network_acls" {
    for_each = var.azure_kv_network_acls != null ? [var.azure_kv_network_acls] : []
    content {
      bypass                     = network_acls.value.bypass
      default_action             = network_acls.value.default_action
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  tags = merge(local.common_tags, var.azure_key_vault_tags)
}

# GCP KMS
resource "google_kms_key_ring" "main" {
  count    = var.cloud_provider == "gcp" && var.enable_gcp_kms ? 1 : 0
  name     = var.gcp_kms_key_ring_name
  location = var.gcp_kms_location
}

resource "google_kms_crypto_key" "main" {
  count    = var.cloud_provider == "gcp" && var.enable_gcp_kms ? 1 : 0
  name     = var.gcp_kms_crypto_key_name
  key_ring = google_kms_key_ring.main[0].id

  rotation_period = var.gcp_kms_rotation_period

  dynamic "version_template" {
    for_each = var.gcp_kms_crypto_key_version_template != null ? [var.gcp_kms_crypto_key_version_template] : []
    content {
      algorithm        = version_template.value.algorithm
      protection_level = version_template.value.protection_level
    }
  }

  labels = merge(local.common_tags, var.gcp_kms_crypto_key_labels)
}

# Certificate Authority (AWS ACM)
resource "aws_acm_certificate" "main" {
  for_each = var.cloud_provider == "aws" ? var.ssl_certificates : {}

  domain_name               = each.value.domain_name
  subject_alternative_names = each.value.subject_alternative_names
  validation_method         = each.value.validation_method

  dynamic "options" {
    for_each = each.value.certificate_transparency_logging_preference != null ? [1] : []
    content {
      certificate_transparency_logging_preference = each.value.certificate_transparency_logging_preference
    }
  }

  tags = merge(local.common_tags, each.value.tags)

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Policies and Roles
resource "aws_iam_policy" "security_policies" {
  for_each = var.cloud_provider == "aws" ? var.iam_policies : {}

  name        = each.value.name
  description = each.value.description
  policy      = each.value.policy_document

  tags = merge(local.common_tags, each.value.tags)
}

resource "aws_iam_role" "security_roles" {
  for_each = var.cloud_provider == "aws" ? var.iam_roles : {}

  name                = each.value.name
  description         = each.value.description
  assume_role_policy  = each.value.assume_role_policy
  max_session_duration = each.value.max_session_duration

  dynamic "inline_policy" {
    for_each = each.value.inline_policies
    content {
      name   = inline_policy.value.name
      policy = inline_policy.value.policy
    }
  }

  tags = merge(local.common_tags, each.value.tags)
}

resource "aws_iam_role_policy_attachment" "security_role_attachments" {
  for_each = var.cloud_provider == "aws" ? local.role_policy_attachments : {}

  role       = aws_iam_role.security_roles[each.value.role_name].name
  policy_arn = each.value.policy_arn
}

# Security Groups
resource "aws_security_group" "security_groups" {
  for_each = var.cloud_provider == "aws" ? var.security_groups : {}

  name        = each.value.name
  description = each.value.description
  vpc_id      = each.value.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      self            = ingress.value.self
      description     = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = each.value.egress_rules
    content {
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
      self            = egress.value.self
      description     = egress.value.description
    }
  }

  tags = merge(local.common_tags, each.value.tags)
}

# WAF (Web Application Firewall)
resource "aws_wafv2_web_acl" "main" {
  for_each = var.cloud_provider == "aws" ? var.waf_web_acls : {}

  name  = each.value.name
  scope = each.value.scope

  default_action {
    dynamic "allow" {
      for_each = each.value.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = each.value.default_action == "block" ? [1] : []
      content {}
    }
  }

  dynamic "rule" {
    for_each = each.value.rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "rate_based_statement" {
          for_each = rule.value.statement_type == "rate_based" ? [rule.value.statement] : []
          content {
            limit              = rate_based_statement.value.limit
            aggregate_key_type = rate_based_statement.value.aggregate_key_type
          }
        }

        dynamic "geo_match_statement" {
          for_each = rule.value.statement_type == "geo_match" ? [rule.value.statement] : []
          content {
            country_codes = geo_match_statement.value.country_codes
          }
        }

        dynamic "ip_set_reference_statement" {
          for_each = rule.value.statement_type == "ip_set" ? [rule.value.statement] : []
          content {
            arn = ip_set_reference_statement.value.arn
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = rule.value.cloudwatch_metrics_enabled
        metric_name                = rule.value.metric_name
        sampled_requests_enabled   = rule.value.sampled_requests_enabled
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = each.value.cloudwatch_metrics_enabled
    metric_name                = each.value.metric_name
    sampled_requests_enabled   = each.value.sampled_requests_enabled
  }

  tags = merge(local.common_tags, each.value.tags)
}

# AWS Config Rules
resource "aws_config_configuration_recorder" "main" {
  count    = var.cloud_provider == "aws" && var.enable_aws_config ? 1 : 0
  name     = var.aws_config_recorder_name
  role_arn = aws_iam_role.config_role[0].arn

  recording_group {
    all_supported                 = var.aws_config_all_supported
    include_global_resource_types = var.aws_config_include_global_resource_types
  }
}

resource "aws_config_delivery_channel" "main" {
  count          = var.cloud_provider == "aws" && var.enable_aws_config ? 1 : 0
  name           = var.aws_config_delivery_channel_name
  s3_bucket_name = var.aws_config_s3_bucket_name
}

resource "aws_config_config_rule" "security_rules" {
  for_each = var.cloud_provider == "aws" && var.enable_aws_config ? var.aws_config_rules : {}

  name = each.value.name

  source {
    owner             = each.value.source_owner
    source_identifier = each.value.source_identifier
  }

  dynamic "scope" {
    for_each = each.value.scope != null ? [each.value.scope] : []
    content {
      compliance_resource_types = scope.value.compliance_resource_types
    }
  }

  depends_on = [aws_config_configuration_recorder.main]

  tags = merge(local.common_tags, each.value.tags)
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  count = var.cloud_provider == "aws" && var.enable_cloudtrail ? 1 : 0

  name           = var.cloudtrail_name
  s3_bucket_name = var.cloudtrail_s3_bucket_name

  event_selector {
    read_write_type                 = var.cloudtrail_read_write_type
    include_management_events       = var.cloudtrail_include_management_events
    exclude_management_event_sources = var.cloudtrail_exclude_management_event_sources

    dynamic "data_resource" {
      for_each = var.cloudtrail_data_resources
      content {
        type   = data_resource.value.type
        values = data_resource.value.values
      }
    }
  }

  advanced_event_selector {
    name = "Log all events"

    field_selector {
      field  = "eventCategory"
      equals = ["Data", "Management"]
    }
  }

  enable_logging                = var.cloudtrail_enable_logging
  enable_log_file_validation    = var.cloudtrail_enable_log_file_validation
  include_global_service_events = var.cloudtrail_include_global_service_events
  is_multi_region_trail         = var.cloudtrail_is_multi_region_trail
  is_organization_trail         = var.cloudtrail_is_organization_trail
  kms_key_id                   = var.enable_kms_encryption ? aws_kms_key.main[0].arn : var.cloudtrail_kms_key_id

  tags = merge(local.common_tags, var.cloudtrail_tags)
}

# GuardDuty
resource "aws_guardduty_detector" "main" {
  count  = var.cloud_provider == "aws" && var.enable_guardduty ? 1 : 0
  enable = true

  datasources {
    s3_logs {
      enable = var.guardduty_s3_logs_enabled
    }
    kubernetes {
      audit_logs {
        enable = var.guardduty_kubernetes_audit_logs_enabled
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.guardduty_malware_protection_enabled
        }
      }
    }
  }

  finding_publishing_frequency = var.guardduty_finding_publishing_frequency

  tags = merge(local.common_tags, var.guardduty_tags)
}

# Security Hub
resource "aws_securityhub_account" "main" {
  count                    = var.cloud_provider == "aws" && var.enable_security_hub ? 1 : 0
  enable_default_standards = var.security_hub_enable_default_standards
}

resource "aws_securityhub_standards_subscription" "standards" {
  for_each      = var.cloud_provider == "aws" && var.enable_security_hub ? toset(var.security_hub_standards) : []
  standards_arn = each.value
  depends_on    = [aws_securityhub_account.main]
}

# Secrets Manager
resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.cloud_provider == "aws" ? var.secrets_manager_secrets : {}

  name                    = each.value.name
  description             = each.value.description
  kms_key_id             = var.enable_kms_encryption ? aws_kms_key.main[0].arn : each.value.kms_key_id
  recovery_window_in_days = each.value.recovery_window_in_days

  dynamic "replica" {
    for_each = each.value.replica_regions
    content {
      region     = replica.value.region
      kms_key_id = replica.value.kms_key_id
    }
  }

  tags = merge(local.common_tags, each.value.tags)
}

resource "aws_secretsmanager_secret_version" "secret_versions" {
  for_each = var.cloud_provider == "aws" ? var.secrets_manager_secrets : {}

  secret_id = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value.secret_string != null ? each.value.secret_string : jsonencode({
    for key, value in each.value.secret_key_value : key => (
      key == "password" && contains(keys(var.generate_database_passwords), each.key) ?
      random_password.database_passwords[each.key].result : value
    )
  })
}

# Data sources
data "aws_caller_identity" "current" {
  count = var.cloud_provider == "aws" ? 1 : 0
}

data "azurerm_client_config" "current" {
  count = var.cloud_provider == "azure" ? 1 : 0
}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    {
      "Module"    = "shared-security"
      "ManagedBy" = "terraform"
    }
  )

  role_policy_attachments = var.cloud_provider == "aws" ? flatten([
    for role_name, role_config in var.iam_roles : [
      for policy_arn in role_config.managed_policy_arns : {
        key        = "${role_name}-${basename(policy_arn)}"
        role_name  = role_name
        policy_arn = policy_arn
      }
    ]
  ]) : []

  # Convert list to map for for_each
  role_policy_attachments_map = var.cloud_provider == "aws" ? {
    for attachment in local.role_policy_attachments :
    attachment.key => attachment
  } : {}
}

# IAM role for AWS Config
resource "aws_iam_role" "config_role" {
  count = var.cloud_provider == "aws" && var.enable_aws_config ? 1 : 0
  name  = "${var.aws_config_recorder_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "config_role_policy" {
  count      = var.cloud_provider == "aws" && var.enable_aws_config ? 1 : 0
  role       = aws_iam_role.config_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/ConfigRole"
}

# Security compliance report
resource "local_file" "security_compliance_report" {
  count = var.generate_security_report ? 1 : 0

  content = templatefile("${path.module}/templates/security-compliance-report.md.tpl", {
    cloud_provider              = var.cloud_provider
    enable_kms_encryption       = var.enable_kms_encryption
    enable_cloudtrail          = var.enable_cloudtrail
    enable_guardduty           = var.enable_guardduty
    enable_security_hub        = var.enable_security_hub
    enable_aws_config          = var.enable_aws_config
    security_groups_count      = length(var.security_groups)
    waf_web_acls_count         = length(var.waf_web_acls)
    ssl_certificates_count     = length(var.ssl_certificates)
    secrets_count              = length(var.secrets_manager_secrets)
    iam_policies_count         = length(var.iam_policies)
    iam_roles_count            = length(var.iam_roles)
    compliance_standards       = var.compliance_standards
    security_hub_standards     = var.security_hub_standards
  })

  filename = "${path.root}/security-compliance-report.md"
}

# Security baseline validation
resource "null_resource" "security_baseline_validation" {
  count = var.validate_security_baseline ? 1 : 0

  triggers = {
    security_config = jsonencode({
      enable_kms_encryption = var.enable_kms_encryption
      enable_cloudtrail    = var.enable_cloudtrail
      enable_guardduty     = var.enable_guardduty
      enable_security_hub  = var.enable_security_hub
      enable_aws_config    = var.enable_aws_config
    })
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Validating security baseline..."
      
      python3 -c "
import json

config = json.loads('${jsonencode({
  enable_kms_encryption = var.enable_kms_encryption
  enable_cloudtrail    = var.enable_cloudtrail
  enable_guardduty     = var.enable_guardduty
  enable_security_hub  = var.enable_security_hub
  enable_aws_config    = var.enable_aws_config
})}')

baseline_checks = {
    'KMS Encryption': config.get('enable_kms_encryption', False),
    'CloudTrail': config.get('enable_cloudtrail', False),
    'GuardDuty': config.get('enable_guardduty', False),
    'Security Hub': config.get('enable_security_hub', False),
    'AWS Config': config.get('enable_aws_config', False)
}

failed_checks = [check for check, enabled in baseline_checks.items() if not enabled]

if failed_checks:
    print(f'Security baseline validation failed. Missing: {failed_checks}')
    print('Consider enabling these security services for better security posture.')
else:
    print('Security baseline validation passed.')

# Save results
with open('${path.root}/security-baseline-validation.json', 'w') as f:
    json.dump({
        'status': 'passed' if not failed_checks else 'warning',
        'failed_checks': failed_checks,
        'passed_checks': [check for check, enabled in baseline_checks.items() if enabled],
        'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
    }, f, indent=2)
      "
    EOT
  }
}