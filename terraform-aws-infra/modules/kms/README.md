# KMS Module (Key Management Service)

**Purpose:** Creates AWS KMS keys for encrypting secrets, databases, S3, and EBS volumes.

## What It Creates

- **KMS Master Key:** Primary encryption key
- **Key Policy:** IAM access control for key usage
- **Key Alias:** Human-readable name for the key
- **Key Rotation:** Automatic annual key rotation
- **CloudTrail Logging:** Audit key usage

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable KMS key creation |
| `description` | string | - | Key description |
| `enable_key_rotation` | bool | `true` | Enable automatic annual rotation |
| `alias` | string | - | Key alias (alias/myapp-key) |
| `administrators` | list(string) | `[]` | IAM ARNs with admin permissions |
| `users` | list(string) | `[]` | IAM ARNs with encrypt/decrypt permissions |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `key_id` | KMS key ID |
| `key_arn` | KMS key ARN (use in policies) |
| `alias_arn` | KMS alias ARN |

## Usage Example

```hcl
module "kms" {
  source = "../../modules/kms"

  create              = true
  description         = "KMS key for myapp production encryption"
  enable_key_rotation = true
  alias               = "alias/myapp-prod"

  administrators = [
    module.iam.security_admin_role_arn
  ]

  users = [
    module.iam.ec2_instance_role_arn,
    module.iam.lambda_execution_role_arn
  ]

  tags = {
    Environment = "prod"
  }
}

# Use for RDS encryption
module "databases" {
  kms_key_id = module.kms.key_arn
}

# Use for S3 encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.myapp.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = module.kms.key_arn
    }
  }
}

# Use for Secrets Manager encryption
module "secrets" {
  kms_key_id = module.kms.key_arn
}
```

## Key Rotation Best Practices

✅ **Enable Auto-Rotation:** AWS rotates keys automatically  
✅ **Audit Usage:** CloudTrail logs all key access  
✅ **Multi-Region:** Replicate keys for disaster recovery  
✅ **Separate Keys:** One per service/environment  

## Phase

**Phase 3** — Encryption
