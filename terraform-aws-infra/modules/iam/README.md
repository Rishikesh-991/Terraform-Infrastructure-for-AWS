# IAM Module

## Overview

Identity and Access Management (IAM) module providing foundational roles and policies following AWS least-privilege principles. Creates environment-specific roles for different workloads while maintaining security best practices.

## Features

✅ **Least-Privilege Access**
- Roles with minimal required permissions
- Resource-specific policies (no wildcards)
- Conditional access where applicable

✅ **Pre-built Role Types**
- EC2 instance profiles
- ECS/EKS application roles
- Lambda execution roles
- RDS enhanced monitoring
- CI/CD and cross-environment roles

✅ **Security Best Practices**
- No hardcoded credentials
- Service principals for assume roles
- Resource tagging for compliance
- External ID support for cross-account

✅ **Environment Isolation**
- Environment-specific naming
- Separate policies per environment
- Easy scaling to multiple accounts

## Architecture

```
┌─────────────────────────────────────┐
│       IAM Roles (Environment)       │
├─────────────────────────────────────┤
│ EC2 Instance Profile                │
│ └─ Basic: SSM, CloudWatch           │
├─────────────────────────────────────┤
│ Application Role (ECS/EKS)          │
│ └─ S3, DynamoDB, Secrets Manager    │
├─────────────────────────────────────┤
│ Lambda Execution Role               │
│ └─ VPC, Secrets, CloudWatch         │
├─────────────────────────────────────┤
│ RDS Monitoring Role                 │
│ └─ CloudWatch Metrics, Logs         │
├─────────────────────────────────────┤
│ Cross-Env CI/CD Role                │
│ └─ CodePipeline, CloudFormation     │
└─────────────────────────────────────┘
```

## Usage

### Basic Deployment

```hcl
module "iam" {
  source = "./modules/iam"

  environment = "dev"

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

### With Cross-Account Access

```hcl
module "iam" {
  source = "./modules/iam"

  environment               = "prod"
  create_cross_account_role = true
  trusted_account_id        = "123456789012"
  external_id               = "unique-external-id"

  tags = {
    Environment = "prod"
  }
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `ec2_instance_profile_name` | EC2 instance profile for launching instances |
| `application_role_arn` | Role for ECS tasks and EKS pods |
| `lambda_execution_role_arn` | Role for Lambda functions |
| `rds_monitoring_role_arn` | Role for RDS enhanced monitoring |
| `cross_env_role_arn` | Role for CI/CD cross-environment access |

## Roles

### 1. EC2 Instance Profile

**Purpose:** Applications running on EC2 instances
**Permissions:**
- SSM Session Manager access
- CloudWatch Logs and Metrics
- CloudWatch agent access

**Use Cases:**
- Web servers
- Application servers
- Bastion hosts

```hcl
# Launch EC2 with profile
resource "aws_instance" "app" {
  iam_instance_profile = module.iam.ec2_instance_profile_name
  # ...
}
```

### 2. Application Role (ECS/EKS)

**Purpose:** Containerized applications
**Permissions:**
- S3 bucket access (pattern: `{env}-app-*`)
- DynamoDB table access
- Secrets Manager read-only
- CloudWatch Logs

**Use Cases:**
- ECS tasks
- EKS pods
- Container applications

```hcl
# ECS task definition
resource "aws_ecs_task_definition" "app" {
  execution_role_arn = module.iam.application_role_arn
  # ...
}
```

### 3. Lambda Execution Role

**Purpose:** Serverless functions
**Permissions:**
- VPC network interface management
- Secrets Manager access
- CloudWatch Logs (via policy attachment)

**Use Cases:**
- VPC Lambda functions
- Async processors
- API backends

```hcl
resource "aws_lambda_function" "processor" {
  role = module.iam.lambda_execution_role_arn
  # ...
}
```

### 4. RDS Monitoring Role

**Purpose:** Enhanced monitoring for databases
**Permissions:**
- Pre-built AWS managed policy
- CloudWatch metrics and logs

**Use Cases:**
- RDS MySQL/PostgreSQL monitoring
- Aurora cluster monitoring

```hcl
resource "aws_db_instance" "primary" {
  monitoring_role_arn = module.iam.rds_monitoring_role_arn
  # ...
}
```

### 5. CI/CD Cross-Environment Role

**Purpose:** Pipeline deployments across environments
**Permissions:**
- ECR image access
- CloudFormation stack management
- Pass roles to services

**Use Cases:**
- CodePipeline
- CodeBuild
- Automated deployments

## Best Practices

### 1. Principle of Least Privilege
Each role has only the minimum permissions needed for its function.

### 2. Resource Naming Patterns
Roles are named by environment and purpose:
- `{env}-ec2-instance-role`
- `{env}-application-role`
- `{env}-lambda-execution-role`

### 3. Adding Custom Permissions
For application-specific access, add policies to existing roles:

```hcl
resource "aws_iam_role_policy" "custom_s3" {
  name   = "dev-app-s3-policy"
  role   = module.iam.application_role_name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:GetObject"
      Resource = "arn:aws:s3:::my-custom-bucket/*"
    }]
  })
}
```

### 4. Cross-Account Access
For multi-account deployments:

```hcl
module "iam" {
  source = "./modules/iam"
  
  environment               = "prod"
  create_cross_account_role = true
  trusted_account_id        = "111111111111"  # Audit account
  external_id               = "generated-unique-id"
}

# In audit account, assume role:
# aws sts assume-role \
#   --role-arn arn:aws:iam::222222222222:role/prod-cross-account-role \
#   --role-session-name audit-session \
#   --external-id generated-unique-id
```

### 5. Monitoring IAM Usage
```bash
# List role usage
aws iam list-role-tags --role-name dev-ec2-instance-role

# Get recent activity
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole
```

## Troubleshooting

### "AccessDenied" when using role

1. Verify role trust policy
2. Check security group outbound rules
3. Verify resource ARNs match policy

```bash
# Check role trust policy
aws iam get-role --role-name dev-ec2-instance-role

# Check attached policies
aws iam list-role-policies --role-name dev-ec2-instance-role
```

### Cross-account access failing

1. Verify external ID matches
2. Check trust relationship
3. Verify both account IDs

```bash
# From trusted account
aws sts assume-role \
  --role-arn arn:aws:iam::ACCOUNT-B:role/cross-account-role \
  --role-session-name session-name \
  --external-id YOUR-EXTERNAL-ID
```

## Cost Implications

**IAM is FREE:**
- No cost for roles, policies, or instance profiles
- Only pay for actual AWS service calls
- Best security investment with zero overhead

## References

- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Policy Examples](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_examples.html)
- [Cross-Account Access](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios_aws-accounts.html)
- [EC2 Instance Profiles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html)

## Next Steps

1. ✅ IAM roles created
2. ➡️ Attach additional policies for specific services
3. ➡️ Configure CloudTrail for audit logging
4. ➡️ Set up IAM Access Analyzer for permission reviews
