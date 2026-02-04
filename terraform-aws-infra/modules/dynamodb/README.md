# DynamoDB Module

**Purpose:** Creates AWS DynamoDB tables for NoSQL data storage with on-demand or provisioned capacity.

## What It Creates

- **DynamoDB Table:** NoSQL database table
- **Primary Key:** Partition key and optional sort key
- **Global Secondary Indexes:** For querying non-key attributes
- **TTL (Time To Live):** Auto-delete old records
- **Encryption:** KMS encryption at rest
- **Point-in-Time Recovery:** Backup and restore capability
- **CloudWatch Monitoring:** Performance metrics

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable table creation |
| `table_name` | string | - | DynamoDB table name |
| `billing_mode` | string | `PAY_PER_REQUEST` | PROVISIONED or PAY_PER_REQUEST |
| `hash_key` | string | - | Partition key name |
| `range_key` | string | - | Sort key name (optional) |
| `hash_key_type` | string | `S` | Data type (S=string, N=number, B=binary) |
| `range_key_type` | string | `S` | Sort key data type |
| `ttl_attribute_name` | string | `` | TTL attribute (empty = disabled) |
| `stream_specification` | object | `{}` | DynamoDB Streams config |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `table_name` | Table name |
| `table_arn` | Table ARN |
| `table_id` | Table ID |
| `stream_arn` | DynamoDB Stream ARN |

## Usage Example

```hcl
module "dynamodb" {
  source = "../../modules/dynamodb"

  create              = true
  table_name          = "myapp-events"
  billing_mode        = "PAY_PER_REQUEST"  # auto-scaling
  hash_key            = "event_id"
  hash_key_type       = "S"
  ttl_attribute_name  = "expiration_time"

  stream_specification = {
    stream_enabled   = true
    stream_view_type = "NEW_AND_OLD_IMAGES"
  }

  tags = {
    Environment = "prod"
  }
}

# Grant Lambda access
resource "aws_iam_policy" "lambda_dynamodb" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query"
        ]
        Resource = module.dynamodb.table_arn
      }
    ]
  })
}

# Use in application
resource "aws_ssm_parameter" "table_name" {
  name  = "/myapp/prod/dynamodb/events"
  value = module.dynamodb.table_name
  type  = "String"
}
```

## Billing Modes

### On-Demand (PAY_PER_REQUEST)
- ✅ Good for: Unpredictable workloads
- ✅ Auto-scaling: Automatic
- ✅ Cost: $1.25 per million read units
- ❌ Not ideal: Consistent, predictable traffic

### Provisioned
- ✅ Good for: Predictable workloads
- ✅ Cost: Cheaper for consistent traffic
- ❌ Manual scaling: Must adjust capacity

## Phase

**Phase 3** — NoSQL Storage
