# Security & Governance skeleton (disabled by default)
resource "aws_guardduty_detector" "this" {
  count = var.create && var.enable_guardduty ? 1 : 0
  enable = true
  finding_publishing_frequency = "SIX_HOURS"
}

resource "aws_securityhub_account" "this" {
  count = var.create && var.enable_security_hub ? 1 : 0
}

resource "aws_config_configuration_recorder" "this" {
  count = var.create && var.enable_config ? 1 : 0
  name = "config-recorder-${var.environment}"
  role_arn = "" # provide role ARN when enabling
  recording_group { all_supported = true include_global_resource_types = true }
}

resource "aws_config_delivery_channel" "this" {
  count = var.create && var.enable_config ? 1 : 0
  name = "delivery-${var.environment}"
  s3_bucket_name = "" # supply bucket when enabling
}

resource "aws_iam_account_password_policy" "hardening" {
  count = var.create ? 1 : 0
  minimum_password_length = 14
  require_symbols = true
  require_numbers = true
  require_uppercase_characters = true
  require_lowercase_characters = true
  allow_users_to_change_password = true
}

# Organization SCPs and other org-level resources are environment dependent — leave skeleton
resource "aws_organizations_policy" "scp_example" {
  count = 0
  name = "deny-noncompliant-${var.environment}"
  content = jsonencode({ Version = "2012-10-17", Statement = [] })
  type = "SERVICE_CONTROL_POLICY"
}
