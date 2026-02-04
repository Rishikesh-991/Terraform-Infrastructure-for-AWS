# IAM Module

**Purpose:** Creates IAM roles and policies for EC2 instances, Lambda functions, applications, and cross-account/cross-environment access.

## What It Creates

- **EC2 Instance Role:** Allows EC2 instances to access AWS services
- **EC2 Instance Profile:** Attaches role to EC2 instances
- **Application Role:** For ECS/EKS tasks, services
- **Lambda Execution Role:** For Lambda functions
- **RDS Monitoring Role:** For enhanced monitoring
- **Cross-Environment Role:** For dev-stage-prod role chaining (optional)
- **Cross-Account Role:** For multi-account access (optional)

## Architecture

```
EC2 Instance
├── → Instance Profile
│   └── → EC2 Instance Role
│       └── Policies:
│           ├── S3 Access (env-scoped)
│           ├── DynamoDB Access
│           ├── Secrets Manager
│           └── CloudWatch Logs

Lambda Function
├── → Lambda Execution Role
│   └── Policies:
│       ├── Logs write
│       ├── S3 read/write
│       └── DynamoDB access

Cross-Account
└── → Cross-Account Role (in Account B)
    └── Trust: Account A
