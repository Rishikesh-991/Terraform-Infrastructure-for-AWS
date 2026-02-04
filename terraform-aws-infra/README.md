# Terraform AWS Infrastructure

Enterprise-grade AWS infrastructure provisioning using Terraform, following AWS Well-Architected Framework principles.

## Repository Structure

```
terraform-aws-infra/
├── backend/                  # Remote state configuration
├── modules/                  # Reusable Terraform modules
│   ├── vpc/                 # Networking
│   ├── iam/                 # Identity and Access Management
│   ├── ec2/                 # Compute
│   ├── alb/                 # Application Load Balancer
│   ├── nlb/                 # Network Load Balancer
│   ├── asg/                 # Auto Scaling Groups
│   ├── rds/                 # Relational Database Service
│   ├── aurora/              # Amazon Aurora
│   ├── eks/                 # Elastic Kubernetes Service
│   ├── ecs/                 # Elastic Container Service
│   ├── lambda/              # AWS Lambda
│   ├── s3/                  # S3 Buckets
│   ├── dynamodb/            # DynamoDB
│   ├── elasticache/         # ElastiCache
│   ├── cloudwatch/          # CloudWatch Logs & Alarms
│   ├── kms/                 # Key Management Service
│   ├── secrets-manager/     # Secrets Manager
│   ├── ssm/                 # Systems Manager Parameter Store
│   └── route53/             # Route 53 DNS
├── environments/            # Environment-specific configurations
│   ├── dev/                 # Development environment
│   ├── stage/               # Staging environment
│   └── prod/                # Production environment
├── global/                  # Global resources and data
├── .github/workflows/       # CI/CD pipelines
└── README.md
```

## Getting Started

### Prerequisites

- Terraform >= 1.0
- AWS Provider >= 5.x
- AWS CLI v2
- AWS credentials configured

### Initial Setup

#### 1. Create Backend Infrastructure (One-time setup)

```bash
cd terraform-aws-infra/backend
terraform init
terraform plan
terraform apply
```

This creates:
- S3 bucket for state storage (versioned, encrypted)
- DynamoDB table for state locking
- CloudTrail for audit logging

#### 2. Initialize Root Module

```bash
cd ..
terraform init
```

#### 3. Create Workspace for Environment

```bash
terraform workspace new dev
terraform workspace select dev
```

### Deployment

#### Development Environment

```bash
cd environments/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

#### Staging Environment

```bash
terraform workspace new stage
terraform workspace select stage
cd environments/stage
terraform plan -out=tfplan
terraform apply tfplan
```

#### Production Environment

```bash
terraform workspace new prod
terraform workspace select prod
cd environments/prod
terraform plan -out=tfplan
terraform apply tfplan
```

### Cleanup

```bash
terraform destroy
```

## Architecture

### Phase 1: Core/Foundation (CURRENT)
- Remote state backend (S3 + DynamoDB)
- VPC with public/private subnets
- Internet Gateway & NAT Gateway
- Route tables and network routing
- Security groups
- Base IAM roles and policies

### Phase 2: Intermediate
- EC2 instances
- Auto Scaling Groups
- Load Balancers (ALB/NLB)
- Databases (RDS, Aurora)
- Cache (ElastiCache)
- DNS (Route 53)

### Phase 3: Advanced
- Kubernetes (EKS)
- Containers (ECS, ECR)
- Serverless (Lambda)
- Event-driven (SQS, SNS, EventBridge)
- Secrets management

### Phase 4: Enterprise/Production
- CI/CD pipelines (CodePipeline, CodeBuild)
- Monitoring & logging (CloudWatch, CloudTrail)
- Security (WAF, GuardDuty, Config)
- Cost optimization

## Environment Configuration

Each environment (dev, stage, prod) uses:
- Same modules for consistency
- Different variable files for configuration
- Terraform workspaces for state isolation
- Consistent tagging for cost tracking

### Variables

- `environment`: Environment name (dev/stage/prod)
- `project`: Project name for tagging
- `region`: AWS region
- `availability_zones`: Number of AZs
- `vpc_cidr`: VPC CIDR block
- `tags`: Common tags for all resources

## Best Practices Implemented

✅ Remote state with encryption and locking
✅ Workspace-aware state management
✅ Modular and reusable components
✅ Least-privilege IAM policies
✅ Security groups with minimal ingress rules
✅ VPC flow logs for monitoring
✅ Consistent tagging strategy
✅ Output values for cross-module reference
✅ Comprehensive variable validation
✅ Production-ready security defaults

## Support & Documentation

Each module contains:
- **main.tf**: Resource definitions
- **variables.tf**: Input variables with defaults and validation
- **outputs.tf**: Output values for consumption
- **README.md**: Module-specific documentation

## Version Control

```bash
git init
git add .
git commit -m "Initial Terraform infrastructure"
git remote add origin <repository-url>
git push -u origin main
```

## Terraform Commands Reference

```bash
# Validation
terraform validate

# Planning
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Destroy
terraform destroy

# Workspace management
terraform workspace new <env>
terraform workspace select <env>
terraform workspace list

# State management
terraform state list
terraform state show <resource>
terraform state rm <resource>
```

## Cost Management

- Use Cost Explorer to monitor spending by environment tag
- Set up billing alerts in CloudWatch
- Review unused resources regularly
- Use spot instances for non-critical workloads

## Troubleshooting

### State Lock Issues

```bash
terraform force-unlock <LOCK_ID>
```

### Provider Issues

```bash
terraform providers mirror ~/.terraform/providers
```

### Module Errors

```bash
terraform validate
terraform fmt -recursive
```

## Contributing

1. Create feature branch: `git checkout -b feature/new-module`
2. Make changes
3. Validate: `terraform validate`
4. Test: `terraform plan`
5. Push and create pull request

## License

Proprietary - Internal Use Only

## Contact

Rishikesh-991
