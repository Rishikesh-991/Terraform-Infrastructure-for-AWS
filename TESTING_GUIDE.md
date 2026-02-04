# Terraform Testing & Validation Guide

Complete guide for validating, testing, and deploying this infrastructure.

## Quick Start: Local Validation

```bash
cd terraform-aws-infra

# Validate syntax
terraform fmt -recursive
terraform validate

# Plan specific environment
terraform -chdir=environments/dev plan -out=dev.tfplan

# Plan without AWS credentials (syntax only)
terraform -chdir=environments/dev init -backend=false
terraform -chdir=environments/dev validate
terraform -chdir=environments/dev plan -lock=false
```

---

## Pre-Deployment Checklist

### Phase 0: Prerequisites

- [ ] AWS Account created
- [ ] AWS credentials configured (`~/.aws/credentials`)
- [ ] Terraform 1.7.2+ installed
- [ ] AWS CLI v2 installed

**Verify Terraform version:**
```bash
terraform --version
# Should output: Terraform v1.7.2 (or newer)
```

**Verify AWS credentials:**
```bash
aws sts get-caller-identity
# Should output: Account ID, User ARN, Account name
```

### Phase 1: Backend Deployment

- [ ] Review backend configuration: `terraform-aws-infra/backend/README.md`
- [ ] No other resources will work without backend

**Deploy backend:**
```bash
cd terraform-aws-infra/backend
terraform init
terraform plan -out=backend.tfplan
terraform apply backend.tfplan

# Capture outputs
terraform output
# Note: s3_bucket_name, dynamodb_table_name, kms_key_id
```

### Phase 2: Environment Configuration

- [ ] Update `environments/dev/backend.tf` with backend outputs
- [ ] Repeat for `stage` and `prod`

**Update backend.tf in each environment:**
```hcl
terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_BACKEND_BUCKET"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "REPLACE_WITH_LOCK_TABLE"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:ACCOUNT:key/ID"
  }
}
```

### Phase 3: Initialize Environments

- [ ] Initialize dev environment with remote backend

**Initialize:**
```bash
cd environments/dev
terraform init
# Confirm: "Do you want to copy existing state to the new backend?"
```

---

## Validation Levels

### Level 1: Syntax Validation (No AWS credentials needed)

```bash
# Format check
terraform fmt -recursive -check terraform-aws-infra/

# Validate syntax
cd terraform-aws-infra/environments/dev
terraform validate

# Expected output: Success! The configuration is valid.
```

**When to use:**
- Local development
- CI/CD pre-checks
- Pre-commit hooks
- No AWS access required

### Level 2: Lint Checking (Optional)

```bash
# Install tflint (https://github.com/terraform-linters/tflint)
brew install tflint

# Run tflint
cd terraform-aws-infra
tflint --recursive

# Expected output: No errors or warnings
```

**When to use:**
- Code quality enforcement
- Best practices checking
- Style consistency

### Level 3: Plan Validation (Requires AWS credentials)

```bash
# Plan without applying
cd terraform-aws-infra/environments/dev
terraform plan -out=dev.tfplan

# Expected output:
# Plan: X to add, 0 to change, 0 to destroy.
```

**What it validates:**
✅ AWS API connectivity
✅ IAM permissions
✅ Resource references
✅ Module dependencies

**Note:** All modules disabled by default (`create = false`), so plan should show minimal changes.

### Level 4: Plan with Enable (Careful!)

```bash
# Enable VPC module only
cd environments/dev

# Create override file
cat > override.tf << 'EOF'
module "vpc" {
  create = true
}
