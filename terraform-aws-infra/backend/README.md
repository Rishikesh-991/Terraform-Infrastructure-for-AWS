# Backend Module

**Purpose:** Creates the remote state backend for Terraform state management across all environments.

## What It Creates

- **S3 Bucket:** Versioned, encrypted bucket for storing terraform.tfstate files
- **DynamoDB Table:** For state locking to prevent concurrent modifications
- **KMS Key:** For encrypting state files at rest
- **CloudTrail:** For auditing access to state files
- **S3 Logging Bucket:** For logging S3 access

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `aws_region` | string | `us-east-1` | AWS region for backend resources |
| `project_name` | string | `terraform` | Project name for resource naming |
| `log_retention_days` | number | `90` | CloudTrail log retention period |
| `enable_mfa_delete` | bool | `false` | Require MFA to delete objects |
| `tags` | map(string) | `{}` | Tags to apply to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `s3_bucket_name` | S3 bucket name for state storage |
| `s3_bucket_arn` | S3 bucket ARN |
| `dynamodb_table_name` | DynamoDB table name for state locking |
| `dynamodb_table_arn` | DynamoDB table ARN |
| `kms_key_id` | KMS key ID for encryption |
| `kms_key_arn` | KMS key ARN |
| `terraform_backend_config` | Complete backend configuration block |

## Usage

### Step 1: Deploy Backend

```bash
cd terraform-aws-infra/backend
terraform init
terraform plan -out=backend.tfplan
terraform apply backend.tfplan
```

### Step 2: Capture Outputs

```bash
terraform output
# Note these values for Step 3
```

### Step 3: Configure Environments

Edit `environments/dev/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "output-s3_bucket_name"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "output-dynamodb_table_name"
    encrypt        = true
    kms_key_id     = "output-kms_key_arn"
  }
}
```

Repeat for `stage` and `prod` environments.

### Step 4: Initialize Environments

```bash
cd ../environments/dev
terraform init  # Connects to remote backend
terraform validate
terraform plan -out=dev.tfplan
```

## Key Security Features

✅ **Versioning Enabled:** Recover previous state if needed  
✅ **KMS Encryption:** All objects encrypted at rest  
✅ **MFA Delete:** Optional extra protection against accidental deletions  
✅ **Access Logging:** All S3 access logged to separate bucket  
✅ **CloudTrail:** All API calls audited  
✅ **Public Access Blocked:** Prevents accidental public exposure  
✅ **DynamoDB Locking:** Prevents concurrent Terraform operations  

## Important Notes

⚠️ **Deploy Once:** Backend should be created once and shared across all environments  
⚠️ **Don't Delete:** Deleting backend removes state history  
⚠️ **Backup S3 Bucket:** Consider cross-region replication for disasters recovery  
⚠️ **Rotate KMS Keys:** Rotate keys annually for security compliance  

## Disaster Recovery

### Restore State From S3 Versioning

```bash
# List all state file versions
aws s3api list-object-versions \
  --bucket output-s3_bucket_name \
  --prefix dev/terraform.tfstate

# Restore specific version
aws s3api get-object \
  --bucket output-s3_bucket_name \
  --key dev/terraform.tfstate \
  --version-id VERSION_ID \
  terraform.tfstate.backup
```

## Phase

**Phase 1** — Foundation (one-time setup)
