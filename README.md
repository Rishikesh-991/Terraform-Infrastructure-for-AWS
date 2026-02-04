# AWS Terraform Infrastructure as Code

**Author:** Rishikesh-991

A production-ready, enterprise-grade AWS infrastructure provisioning framework using Terraform, implementing AWS Well-Architected Framework best practices across 6 deployment phases.

## 📋 Project Overview

This project provides a modular, scalable Terraform codebase for deploying a complete AWS infrastructure spanning networking, compute, databases, containers, security, and observability. All resources are organized into reusable modules with environment-specific configurations (dev, stage, prod).

### Key Features

- **Modular Architecture:** 30+ independent, reusable Terraform modules
- **Multi-Environment Support:** Dev, stage, and production configurations with shared module definitions
- **Remote State Management:** S3 backend with DynamoDB locking and KMS encryption
- **Safety First:** All modules disabled by default; enable selectively per environment
- **CI/CD Ready:** GitHub Actions workflows for validation and formatting checks
- **Well-Architected:** Built to AWS best practices: security, cost optimization, operational excellence
- **Comprehensive Logging:** CloudWatch integration, audit trails, and monitoring

### Service Coverage

**Phase 1 — Networking & Compute Foundation**
- VPC with multi-AZ subnets, NAT gateways, and gateway endpoints
- Route tables, security groups, internet gateway
- IAM roles, instance profiles, cross-account access
- EC2 launch templates with safe defaults (no instances created by default)

**Phase 2 — Bastion, Monitoring & Secrets**
- Bastion host + SSM Session Manager
- CloudWatch dashboards, log groups, and alarms
- Secrets Manager and SSM Parameter Store integration
- CI/CD pipeline IAM roles and GitHub Actions workflow

**Phase 3 — Containers & Databases**
- ECS cluster skeleton with task definitions
- EKS with managed node groups support
- RDS (Aurora PostgreSQL/MySQL, standard RDS)
- DynamoDB tables
- ElastiCache (Redis) clusters

**Phase 4 — Security & Networking**
- GuardDuty threat detection
- AWS Config compliance monitoring
- Security Hub
- Transit Gateway for multi-VPC routing

**Phase 5 — Observability & Cost**
- Centralized CloudWatch logging
- Cost budgets and cost allocation tags
- Dashboard templates

**Phase 6 — CI/CD & Testing**
- Pre-commit hooks for code quality
- Local validation scripts
- GitHub Actions CI checks

---

## 🚀 Installation & Setup Guide

### Prerequisites

Before you begin, ensure you have:

1. **Terraform** >= 1.0
   ```bash
   terraform --version
   ```
   [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

2. **AWS CLI** v2
   ```bash
   aws --version
   ```
   [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

3. **AWS Account** with sufficient permissions (Admin or custom policy)

4. **AWS Credentials** configured
   ```bash
   aws configure
   # Enter: Access Key, Secret Key, Default Region, Output Format
   ```

5. **Git** for version control (recommended)

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/AWS-terraform.git
cd AWS-terraform
```

### Step 2: Review Project Structure

```bash
tree terraform-aws-infra -L 2
```

Key directories:
- `terraform-aws-infra/backend/` — Remote state S3 + DynamoDB (deploy once)
- `terraform-aws-infra/modules/` — 30+ reusable Terraform modules
- `terraform-aws-infra/environments/` — Dev, stage, prod configurations
- `scripts/local/` — Local validation scripts
- `.github/workflows/` — CI/CD automation

### Step 3: Deploy Remote State Backend (One-Time Setup)

The backend must be created first to store Terraform state remotely and enable team collaboration.

```bash
cd terraform-aws-infra/backend

# Review the backend configuration
cat README.md

# Initialize, plan, and apply
terraform init
terraform plan -out=backend.tfplan
terraform apply backend.tfplan
```

**Output notes:** After apply, you'll see outputs including:
- `s3_bucket_name` — Use in `backend.tf`
- `dynamodb_table_name` — Use in `backend.tf`
- `kms_key_arn` — Optional, for encryption

### Step 4: Configure Environment Backend

After backend deployment, update the environment-specific `backend.tf` files:

```bash
# For dev environment
cd ../environments/dev

# Edit backend.tf and replace placeholders with outputs from backend apply
# Example:
cat backend.tf
# Replace:
# - REPLACE_WITH_BUCKET_NAME → s3_bucket_name output
# - REPLACE_WITH_DYNAMODB_TABLE → dynamodb_table_name output
# - REPLACE_WITH_KMS_KEY_ARN → kms_key_arn output

# Repeat for stage and prod environments
cd ../stage
# ... edit backend.tf
cd ../prod
# ... edit backend.tf
```

### Step 5: Initialize Environment (With Remote Backend)

```bash
cd terraform-aws-infra/environments/dev

# Initialize with remote backend
terraform init

# Validate configuration
terraform validate

# Review planned changes (no resources created yet)
terraform plan -out=dev.tfplan
```

If you see errors related to backend bucket access, ensure:
- AWS credentials have S3 and DynamoDB permissions
- Bucket name and region are correct in `backend.tf`
- KMS key ARN (if used) is accessible

### Step 6: Enable Resources (Optional)

By default, all modules are disabled (`create = false`). To enable specific resources:

**Example: Enable VPC**

Edit `terraform-aws-infra/environments/dev/main.tf`:

```hcl
module "vpc" {
  source = "../../modules/vpc"
  environment = var.environment
  # Other inputs...
}
```

VPC is enabled by default. To enable other services (e.g., ECS), edit `variables.tf`:

```hcl
variable "enable_ecs" {
  default = true
}
```

Then reference it in `main.tf`:

```hcl
module "ecs" {
  source = "../../modules/ecs"
  environment = var.environment
  create = var.enable_ecs
}
```

### Step 7: Deploy Infrastructure

```bash
cd terraform-aws-infra/environments/dev

# Plan changes
terraform plan -out=dev.tfplan

# Review the output carefully (costs, resources, dependencies)

# Apply only if you approve
terraform apply dev.tfplan
```

⚠️ **WARNING:** Applying this will create AWS resources and incur charges. Always review the plan first.

---

## 📚 Module Usage Reference

### VPC Module
Deploys a multi-AZ VPC with public/private subnets, NAT gateways, and endpoints.

```hcl
module "vpc" {
  source = "../../modules/vpc"
  environment = "dev"
  vpc_cidr_block = "10.0.0.0/16"
  number_of_availability_zones = 2
  create_s3_endpoint = true
  create_dynamodb_endpoint = true
}
```

**Key outputs:** `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `nat_gateway_ids`

### IAM Module
Creates roles for EC2, Lambda, RDS monitoring, and cross-account access.

```hcl
module "iam" {
  source = "../../modules/iam"
  environment = "dev"
  create_cross_env_role = true
  trusted_account_id = "123456789012"
}
```

**Key outputs:** `ec2_instance_profile_name`, `application_role_arn`, `lambda_role_arn`

### Security Groups Module
Manages bastion, application, and database security groups.

```hcl
module "security_groups" {
  source = "../../modules/security-groups"
  environment = "dev"
  vpc_id = module.vpc.vpc_id
  management_cidrs = ["203.0.113.0/24"]
}
```

**Key outputs:** `app_sg_id`, `db_sg_id`, `bastion_sg_id`

### ECS Module
Provisions an ECS cluster for containerized workloads.

```hcl
module "ecs" {
  source = "../../modules/ecs"
  environment = "dev"
  create = true
}
```

**Key outputs:** `cluster_id`

See `terraform-aws-infra/modules/*/README.md` for detailed module documentation.

---

## 🔍 Validation & Testing

### Local Validation (No AWS Resources)

Validate all environments without deploying resources:

```bash
./scripts/local/validate_all.sh
```

This script runs `terraform init -backend=false` and `terraform validate` for dev, stage, and prod.

### Per-Environment Validation

```bash
cd terraform-aws-infra/environments/dev
terraform init -backend=false
terraform validate
terraform plan -out=tfplan  # Review changes
```

### CI/CD Validation

GitHub Actions automatically runs:
- `terraform fmt -check` — Code formatting check
- `terraform validate` — Syntax validation

See `.github/workflows/ci-checks.yml` for pipeline details.

---

## 🛠️ Development & Contributing

### Setup Development Environment

1. **Install pre-commit hooks:**
   ```bash
   pip install pre-commit
   pre-commit install
   ```

2. **Run local validation:**
   ```bash
   ./scripts/local/validate_all.sh
   ```

3. **Format Terraform files:**
   ```bash
   terraform fmt -recursive terraform-aws-infra/
   ```

### Project Structure Best Practices

- **Modules:** Self-contained, reusable components with clear inputs/outputs
- **Environments:** Shared modules, environment-specific variables
- **Backend:** Centralized state, locked for team safety
- **CI/CD:** Automated validation on every push/PR

### Adding a New Module

1. Create module directory:
   ```bash
   mkdir terraform-aws-infra/modules/mymodule
   ```

2. Create required files:
   ```bash
   touch terraform-aws-infra/modules/mymodule/{main.tf,variables.tf,outputs.tf,README.md}
   ```

3. Implement resources in `main.tf` with safe defaults (e.g., `create = false`)

4. Wire into environments:
   ```hcl
   module "mymodule" {
     source = "../../modules/mymodule"
     environment = var.environment
     create = false  # Disabled by default
   }
   ```

---

## 🔐 Security Considerations

### State Management
- **Remote backend:** S3 with versioning + DynamoDB locking
- **Encryption:** KMS keys for S3 objects
- **Access:** Restricted IAM policy (principle of least privilege)

### Secrets
- Use **Secrets Manager** for sensitive data (API keys, passwords, DB credentials)
- Use **SSM Parameter Store** for non-sensitive configuration
- Never commit secrets to version control (use `.gitignore`)

### IAM & Access
- All IAM roles use least-privilege policies
- Cross-account roles require explicit `trusted_account_id`
- Instance profiles attached to EC2 instead of hardcoding credentials

### Networking
- Security groups default to deny-all ingress
- Public subnets only for ALB/NLB
- Private subnets for databases, Lambda, and internal services

---

## 💰 Cost Optimization

### Default Safe Settings
- EC2 instances: disabled by default
- RDS: t3.medium (burstable, cost-effective)
- ElastiCache: t3.micro with 1 node
- DynamoDB: PAY_PER_REQUEST billing
- CloudWatch logs: 30-day retention

### Cost Monitoring
- AWS Cost Explorer integration (enable via `cost` module)
- Budget alerts configured per environment
- Cost allocation tags applied to all resources

### Next Steps for Optimization
- Use Reserved Instances for production workloads
- Enable Auto Scaling for compute resources
- Use Spot Instances for batch jobs
- Implement lifecycle policies for S3/logs

---

## 📖 Documentation

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/)
- Module-specific READMEs: `terraform-aws-infra/modules/*/README.md`
- Local testing guide: `CONTRIBUTING.md`
- Runbooks: `terraform-aws-infra/RUNBOOKS.md`

---

## 🐛 Troubleshooting

### "No configuration files" Error
**Cause:** Running Terraform from a directory without `.tf` files
**Solution:**
```bash
cd terraform-aws-infra/environments/dev
terraform validate
```

### "Error: Missing required argument 'backend_config'"
**Cause:** `backend.tf` has placeholder values
**Solution:** Replace placeholders in `backend.tf` with actual S3 bucket name, DynamoDB table, KMS ARN from backend apply output

### "Error: Access Denied" (S3/DynamoDB)
**Cause:** AWS credentials lack required permissions
**Solution:**
```bash
aws sts get-caller-identity  # Verify credentials
# Ensure IAM user/role has s3:GetObject, dynamodb:GetItem, kms:Decrypt permissions
```

### Terraform State Lock Issues
**Check lock:**
```bash
terraform force-unlock <LOCK_ID>
```

**Solution:** Ensure only one operation runs at a time; use `-lock-timeout` if needed

---

## 📝 License

[Specify your license here, e.g., MIT, Apache 2.0, etc.]

---

## 🤝 Support & Contributions

For issues, feature requests, or contributions:

1. Open an issue describing the problem
2. Fork the repository
3. Create a feature branch: `git checkout -b feature/my-feature`
4. Commit changes: `git commit -m "feat: add my-feature"`
5. Push and create a Pull Request

---

**Terraform Version:** >= 1.0
**AWS Provider:** >= 5.0
**Author:** Rishikesh-991
