# AWS Infrastructure Architecture

## Overview

This Terraform project deploys a multi-tier, multi-environment AWS infrastructure following AWS Well-Architected Framework principles.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         VPC (10.0.0.0/16)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────┐     ┌──────────────────────────┐  │
│  │   Availability Zone 1    │     │   Availability Zone 2    │  │
│  ├──────────────────────────┤     ├──────────────────────────┤  │
│  │                          │     │                          │  │
│  │ ┌────────────────────┐   │     │ ┌────────────────────┐   │  │
│  │ │ Public Subnet      │   │     │ │ Public Subnet      │   │  │
│  │ │ (10.0.1.0/24)      │   │     │ │ (10.0.3.0/24)      │   │  │
│  │ ├────────────────────┤   │     │ ├────────────────────┤   │  │
│  │ │  ALB/NLB           │   │     │  ALB/NLB (HA)       │   │  │
│  │ │  Bastion Host      │   │     │  Bastion Host (HA)  │   │  │
│  │ │  (SSM Session Mgr) │   │     │  (SSM Session Mgr)  │   │  │
│  │ └────────────────────┘   │     │ └────────────────────┘   │  │
│  │          │                │            │                  │  │
│  │ ┌────────▼────────────┐   │     │ ┌────────▼────────────┐ │  │
│  │ │ Private Subnet      │   │     │ │ Private Subnet      │ │  │
│  │ │ (10.0.2.0/24)       │   │     │ │ (10.0.4.0/24)       │ │  │
│  │ ├─────────────────────┤   │     │ ├─────────────────────┤ │  │
│  │ │  EC2 Instances      │   │     │  EC2 Instances      │ │  │
│  │ │  Lambda             │   │     │  Lambda             │ │  │
│  │ │  ECS/EKS Tasks      │   │     │  ECS/EKS Tasks      │ │  │
│  │ │  (via NAT Gateway)  │   │     │  (via NAT Gateway)  │ │  │
│  │ └─────────────────────┘   │     │ └─────────────────────┘ │  │
│  │                           │     │                         │  │
│  └───────────────────────────┘     └─────────────────────────┘  │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │             Database Subnet Group (Private)                │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │                                                             │ │
│  │  ┌──────────────────────┐     ┌──────────────────────┐   │ │
│  │  │  RDS Aurora (Multi-AZ)   │  ElastiCache (Redis)  │   │ │
│  │  │  or RDS PostgreSQL/MySQL │  DynamoDB Tables      │   │ │
│  │  └──────────────────────┘     └──────────────────────┘   │ │
│  │                                                             │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
         │                                          │
         ▼                                          ▼
    ┌─────────────┐                           ┌──────────────┐
    │    IGW      │                           │  NAT Gateway │
    │  (Internet  │                           │ (via EIP)    │
    │  Gateway)   │                           │              │
    └─────────────┘                           └──────────────┘
         │                                          │
         ▼                                          ▼
    ┌─────────────────────────────────────────────────┐
    │        AWS Internet / External Services         │
    │   (S3, Secrets Manager, Systems Manager, etc.)  │
    └─────────────────────────────────────────────────┘
```

## Security Groups Hierarchy

```
┌─────────────────────────────────────────────────────┐
│          ALB/NLB Security Group                     │
│  Inbound: 80, 443 from 0.0.0.0/0                  │
│  Outbound: All to EC2 SG                           │
└────────────────┬────────────────────────────────────┘
                 │
         ┌───────▼───────┐
         │               │
    ┌────▼────────┐  ┌───▼──────────┐
    │  EC2 SG     │  │ Bastion SG   │
    │ Inbound:    │  │ Inbound:     │
    │  80, 443    │  │  22 (SSH)    │
    │  from ALB   │  │  from AdminIP│
    │ Outbound:   │  │ Outbound:    │
    │  to RDS SG  │  │  to all      │
    └────┬────────┘  └──────────────┘
         │
    ┌────▼──────────────┐
    │  RDS SG           │
    │  Inbound: 3306    │
    │  from EC2 SG      │
    │  Outbound: None   │
    └───────────────────┘
```

## Data Flow

### Inbound (Internet → Application)
1. Internet traffic hits ALB/NLB on ports 80/443
2. ALB/NLB routes to EC2 instances in private subnets
3. EC2 instances process requests
4. Bastion host available for SSH via SSM Session Manager (no public IP)

### Outbound (Application → Internet)
1. EC2 instances in private subnets route through NAT Gateway
2. NAT Gateway translates traffic through public subnet
3. NAT Gateway uses Elastic IP to reach Internet
4. Return traffic flows back through NAT

### Database Access
1. EC2 instances connect to RDS via security group rules
2. RDS resides in database subnet group
3. Multi-AZ failover handled by RDS

### External Services
1. S3: Via Gateway VPC Endpoint (free, optimized)
2. DynamoDB: Via Gateway VPC Endpoint
3. Secrets Manager: Via Interface Endpoint
4. Systems Manager (SSM): Via Interface Endpoint

## Environment Isolation

```
┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
│   Development (dev)  │  │   Staging (stage)    │  │   Production (prod)  │
├──────────────────────┤  ├──────────────────────┤  ├──────────────────────┤
│ VPC: 10.0.0.0/16     │  │ VPC: 10.1.0.0/16     │  │ VPC: 10.2.0.0/16     │
│ RDS: t3.medium       │  │ RDS: r5.large        │  │ RDS: r5.xlarge (HA)  │
│ ASG: 1-2 instances   │  │ ASG: 2-4 instances   │  │ ASG: 3-10 instances  │
│ Bastion: 1           │  │ Bastion: 1           │  │ Bastion: 2 (HA)      │
│ Backup: Daily        │  │ Backup: Daily        │  │ Backup: Hourly       │
│ Monitoring: Basic    │  │ Monitoring: Standard │  │ Monitoring: Enhanced │
└──────────────────────┘  └──────────────────────┘  └──────────────────────┘
```

## State Management

```
┌──────────────────────────────────────────────────────────────┐
│  Remote State Backend (Shared Across All Environments)       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  S3 Bucket (terraform-state-{env})                     │ │
│  │  - Versioning Enabled                                  │ │
│  │  - Encryption (KMS)                                    │ │
│  │  - MFA Delete (optional)                               │ │
│  │  - Public Access Blocked                               │ │
│  │  - Logging to another S3 bucket                        │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  DynamoDB Table (terraform-locks)                      │ │
│  │  - Partition Key: LockID                               │ │
│  │  - Prevents concurrent applies                         │ │
│  │  - Automatic cleanup on unlock                         │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  KMS Key (terraform-state-key)                         │ │
│  │  - SSE-KMS encryption for S3 objects                   │ │
│  │  - Audit trail via CloudTrail                          │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Deployment Workflow

```
1. Clone Repository
   ↓
2. Deploy Backend (S3, DynamoDB, KMS) — One-time setup
   ↓
3. Configure Environment (dev/stage/prod)
   ├─ Copy backend outputs
   ├─ Set environment variables
   └─ Update variables.tfvars
   ↓
4. Initialize Terraform
   ├─ terraform init (connects to remote backend)
   ├─ terraform workspace select <env>
   └─ terraform validate
   ↓
5. Plan Changes
   └─ terraform plan -out=<env>.tfplan
   ↓
6. Review & Approve
   ├─ Read full plan output
   ├─ Verify cost estimates
   └─ Confirm no destructive changes
   ↓
7. Apply (If Approved)
   └─ terraform apply <env>.tfplan
   ↓
8. Monitor & Validate
   ├─ Check CloudWatch logs
   ├─ Verify resource creation
   ├─ Run smoke tests
   └─ Monitor costs
```

## Disaster Recovery

- **Backup Strategy:** Automated daily snapshots for RDS, EBS, DynamoDB
- **Recovery Time Objective (RTO):** < 1 hour for full restoration
- **Recovery Point Objective (RPO):** < 24 hours for data loss tolerance
- **Cross-Region Replication:** Optional for production (enable via module variables)

## Cost Optimization

- All non-production resources use burstable instance types (t3.medium, t3.micro)
- Auto Scaling groups scale down to 0 during off-hours (optional)
- Reserved Instances recommended for production baseline
- Spot Instances for non-critical workloads
- Lifecycle policies delete old snapshots after 30 days

## Monitoring & Logging

- **CloudWatch:** All metrics, logs, dashboards
- **CloudTrail:** API audit logs, stored in S3
- **GuardDuty:** Threat detection
- **VPC Flow Logs:** Network traffic analysis
- **Config:** Resource compliance tracking

