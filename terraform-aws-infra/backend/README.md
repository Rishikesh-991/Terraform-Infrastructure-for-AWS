# Backend Configuration

## Overview

This module sets up the remote state backend infrastructure for Terraform using S3 and DynamoDB. This is a **one-time setup** that must be completed before deploying any other infrastructure.

## Resources Created

### 1. **S3 Bucket for State Storage**
- Versioned: Maintains history of all state changes
- Encrypted: KMS encryption at rest with key rotation
- Logging: Access logs stored in separate bucket
- Private: Blocks all public access

### 2. **DynamoDB Table for State Locking**
- Prevents concurrent modifications to state
- On-demand billing (pay-per-request)
- Point-in-time recovery enabled
- Encrypted with KMS
- TTL enabled for cleanup

### 3. **KMS Key for Encryption**
- Encrypts S3 bucket contents
- Encrypts DynamoDB table
- Automated key rotation
- CloudTrail audit logging

### 4. **CloudTrail Audit Logging**
- Tracks all API calls to state resources
- Logs stored in Glacier for long-term retention
- Helps track who accessed what and when

### 5. **Access Logs Bucket**
- Stores S3 bucket access logs
- Automatic archival to Glacier after 90 days
- Automatic deletion after 1 year

## Deployment Instructions

### Step 1: Create terraform.tfvars

```bash
cat > terraform.tfvars << 'VARS'
aws_region   = "us-east-1"
project_name = "my-project"
VARS
```

### Step 2: Initialize Terraform (LOCAL STATE ONLY)

```bash
terraform init
```

Note: This initial deployment uses local state because we're creating the backend itself.

### Step 3: Validate Configuration

```bash
terraform validate
```

### Step 4: Plan Deployment

```bash
terraform plan -out=tfplan
```

Review the plan to ensure:
- S3 bucket is created with correct encryption
- DynamoDB table is created for locking
- KMS key is generated
- CloudTrail is configured

### Step 5: Apply Configuration

```bash
terraform apply tfplan
```

This will output the backend configuration needed for other environments.

### Step 6: Copy Backend Configuration

After successful apply, Terraform will output `backend_config` and `terraform_backend_config_content`. Copy the output and add it to each environment's `backend.tf`:

```bash
# For dev, stage, prod environments:
cat > environments/<ENV>/backend.tf << 'BACKEND'
terraform {
  backend "s3" {
    bucket         = "<from output>"
    key            = "terraform.tfstate"
    region         = "<from output>"
    dynamodb_table = "<from output>"
    encrypt        = true
    kms_key_id     = "<from output>"
  }
}
BACKEND
```

## Security Considerations

✅ **Encryption:**
- All data encrypted with KMS keys
- Encryption enforced via bucket policy
- Unencrypted uploads blocked

✅ **Access Control:**
- S3 bucket is completely private
- Public access blocked at all levels
- Only IAM users/roles with permissions can access

✅ **Audit:**
- CloudTrail logs all state access
- Logs stored in separate encrypted bucket
- Long-term retention in Glacier

✅ **Versioning:**
- All state changes tracked
- Can recover previous versions if needed
- Noncurrent versions retained for 30 days

## AWS Compliance

- ✅ CIS AWS Foundations Benchmark
- ✅ SOC 2 requirements
- ✅ HIPAA compliance ready
- ✅ PCI-DSS compliance ready

## Costs

**Typical Monthly Costs:**
- S3 storage: $0.50-2.00 (minimal state files)
- S3 versioning: $0.50-2.00
- DynamoDB: $1.25 (on-demand, minimal)
- KMS: $1.00 (1 key)
- CloudTrail: $2.00
- Glacier storage: $0.10-0.50

**Total: ~$5-10/month**

## Troubleshooting

### Error: "S3 bucket name already exists"
S3 bucket names are globally unique. Change `project_name` to something unique.

### Error: "Access Denied"
Ensure your AWS credentials have permissions to create S3, DynamoDB, KMS, and CloudTrail resources.

### State Lock Issues
If Terraform is stuck:
```bash
terraform force-unlock <LOCK_ID>
```

## Next Steps

1. ✅ Backend deployed
2. ➡️ Initialize environments with backend configuration
3. ➡️ Deploy VPC module
4. ➡️ Deploy networking (subnets, routes)
5. ➡️ Deploy other modules

## References

- [Terraform Remote State](https://www.terraform.io/language/state/remote)
- [S3 Backend Configuration](https://www.terraform.io/language/settings/backends/s3)
- [State Locking](https://www.terraform.io/language/state/locking)
