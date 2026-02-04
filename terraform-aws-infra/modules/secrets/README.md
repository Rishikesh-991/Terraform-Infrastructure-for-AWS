# Secrets Manager Module

**Purpose:** Creates AWS Secrets Manager secrets for database passwords, API keys, and credentials.

## What It Creates

- **Secret:** Encrypted secret value in Secrets Manager
- **Secret Version:** Current version of secret (supports rotation)
- **Secret Policy:** IAM access control
- **CloudTrail Logging:** Audit secret access

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable secret creation |
| `secret_name` | string | - | Secret name in Secrets Manager |
| `secret_value` | string | - | Secret value (password, API key, JSON) |
| `recovery_window` | number | `7` | Days before deletion (7-30) |
| `enable_rotation` | bool | `false` | Enable automatic rotation |
| `rotation_days` | number | `30` | Rotation frequency (days) |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `secret_id` | Secret ID (use in references) |
| `secret_arn` | Secret ARN (for IAM policies) |
| `secret_version` | Current secret version |

## Usage Example

```hcl
# Generate random password
resource "random_password" "db_password" {
  length  = 32
  special = true
}

module "secrets" {
  source = "../../modules/secrets"

  create         = true
  secret_name    = "myapp/prod/db/password"
  secret_value   = random_password.db_password.result
  recovery_window = 30
  enable_rotation = true
  rotation_days  = 90

  tags = {
    Environment = "prod"
  }
}

# Retrieve secret in code
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = module.secrets.secret_id
}

# Use in RDS
module "databases" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}

# Grant IAM role access
resource "aws_secretsmanager_secret_target_attachment" "db_secret" {
  secret_id           = module.secrets.secret_id
  target_id           = aws_db_instance.myapp.resource_id
  target_type         = "RDS"
}
```

## Secrets Naming Convention

Use hierarchical names for organization:

```
/myapp/dev/db/password
/myapp/dev/github/token
/myapp/prod/api/key
/myapp/prod/oauth/secret
```

## Phase

**Phase 3** — Secrets Management
