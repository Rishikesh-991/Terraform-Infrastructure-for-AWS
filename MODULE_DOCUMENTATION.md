# Module Documentation Guide

Complete reference for all 30+ Terraform modules in this infrastructure repository.

## Quick Navigation

### Phase 1: Foundation & Networking
- [Backend](#backend-module) — Remote state management
- [VPC](#vpc-module) — Virtual Private Cloud
- [Security Groups](#security-groups-module) — Network access control
- [Route Tables](#route-tables-module) — Network routing
- [IAM](#iam-module) — Identity & Access Management

### Phase 2: Compute & Load Balancing
- [EC2](#ec2-module) — Virtual servers
- [ASG](#asg-module) — Auto Scaling Groups
- [ALB](#alb-module) — Application Load Balancer
- [NLB](#nlb-module) — Network Load Balancer
- [Monitoring](#monitoring-module) — CloudWatch dashboards
- [Route53](#route53-module) — DNS management

### Phase 3: Databases & Caching
- [RDS/Databases](#databases-module) — Managed relational databases
- [Aurora](#aurora-module) — Managed Aurora clusters
- [ElastiCache](#elasticache-module) — Redis/Memcached
- [DynamoDB](#dynamodb-module) — NoSQL tables

### Phase 3: Serverless & Secrets
- [Lambda](#lambda-module) — Serverless functions
- [Secrets Manager](#secrets-module) — Secrets storage
- [KMS](#kms-module) — Encryption keys

### Phase 4 & Beyond
- [ECS](#ecs-module) — Container orchestration
- [EKS](#eks-module) — Kubernetes
- [Bastion SSM](#bastion-ssm-module) — Secure shell access
- [CICD](#cicd-module) — CI/CD pipelines
- [Cost Optimization](#cost-module) — Cost tracking
- [Observability](#observability-module) — Logging & tracing
- [Security Governance](#security-governance-module) — Compliance
- [Transit Gateway](#transit-gateway-module) — Network connectivity

---

## Module Details

### Backend Module

**Location:** [terraform-aws-infra/backend/](terraform-aws-infra/backend/)

**Purpose:** Creates remote state backend infrastructure for all environments.

**Resources Created:**
- Versioned S3 bucket with encryption
- DynamoDB table for state locking
- KMS encryption key
- CloudTrail for audit logging
- S3 logging bucket

**Key Inputs:**
| Input | Type | Default | Purpose |
|-------|------|---------|---------|
| `aws_region` | string | `us-east-1` | Backend region |
| `project_name` | string | `terraform` | Resource naming |
| `log_retention_days` | number | `90` | CloudTrail retention |
| `enable_mfa_delete` | bool | `false` | MFA protection |

**Key Outputs:**
| Output | Purpose |
|--------|---------|
| `s3_bucket_name` | Backend bucket name |
| `dynamodb_table_name` | State lock table |
| `kms_key_id` | Encryption key ID |
| `terraform_backend_config` | Ready-to-use backend config |

**Usage Guide:**
See [Backend Module README](terraform-aws-infra/backend/README.md)

---

### VPC Module

**Location:** [terraform-aws-infra/modules/vpc/](terraform-aws-infra/modules/vpc/)

**Purpose:** Creates multi-AZ VPC with subnets, gateways, and endpoints.

**Resources Created:**
- VPC with custom CIDR
- Public subnets (1 per AZ)
- Private subnets (1 per AZ)
- Internet Gateway
- NAT Gateways (1 per AZ)
- VPC Flow Logs
- S3 & DynamoDB gateway endpoints

**Key Inputs:**
| Input | Type | Default | Purpose |
|-------|------|---------|---------|
| `vpc_cidr_block` | string | `10.0.0.0/16` | VPC CIDR range |
| `number_of_availability_zones` | number | `2` | Multi-AZ count |
| `public_subnet_bits` | number | `4` | Public subnet mask |
| `private_subnet_bits` | number | `4` | Private subnet mask |

**Key Outputs:**
| Output | Purpose |
|--------|---------|
| `vpc_id` | VPC identifier |
| `public_subnet_ids` | Public subnet IDs |
| `private_subnet_ids` | Private subnet IDs |
| `nat_gateway_ids` | NAT Gateway IDs |

**Network Diagram:**
```
VPC (10.0.0.0/16)
├── AZ-1
│   ├── Public (10.0.1.0/24) → IGW
│   └── Private (10.0.2.0/24) → NAT-1
├── AZ-2
│   ├── Public (10.0.3.0/24) → IGW
│   └── Private (10.0.4.0/24) → NAT-2
└── Endpoints: S3, DynamoDB
```

**Usage Guide:**
See [VPC Module README](terraform-aws-infra/modules/vpc/README.md)

---

### Security Groups Module

**Location:** [terraform-aws-infra/modules/security-groups/](terraform-aws-infra/modules/security-groups/)

**Purpose:** Creates layered security groups for ALB, EC2, and RDS.

**Security Groups Created:**
- Bastion SG (SSH access via SSM)
- Application SG (HTTP/HTTPS traffic)
- Database SG (restricted inbound from app only)

**Principle:** Least Privilege
- Database SG: Inbound from app only, no outbound
- Application SG: Inbound from ALB, outbound unrestricted
- Bastion SG: Inbound from management CIDRs

**Key Inputs:**
| Input | Type | Default | Purpose |
|-------|------|---------|---------|
| `vpc_id` | string | - | VPC for SGs |
| `management_cidrs` | list(string) | `["0.0.0.0/0"]` | Admin access |
| `alb_allowed_cidrs` | list(string) | `["0.0.0.0/0"]` | Web traffic |
| `db_port` | number | `5432` | Database port |

**Usage Guide:**
See [Security Groups Module README](terraform-aws-infra/modules/security-groups/README.md)

---

### IAM Module

**Location:** [terraform-aws-infra/modules/iam/](terraform-aws-infra/modules/iam/)

**Purpose:** Creates IAM roles and policies for compute, databases, and services.

**Roles Created:**
- EC2 Instance Role → S3, DynamoDB, Secrets Manager
- Lambda Execution Role → Logs, VPC, X-Ray
- Application Role → ECS/EKS tasks
- RDS Monitoring Role
- Cross-environment & cross-account roles (optional)

**Key Principle:** Service-specific permissions
- EC2: S3 buckets, DynamoDB tables, Secrets Manager
- Lambda: CloudWatch Logs, VPC access, DynamoDB
- RDS: Enhanced monitoring

**Usage Guide:**
See [IAM Module README](terraform-aws-infra/modules/iam/README.md)

---

### EC2 Module

**Location:** [terraform-aws-infra/modules/ec2/](terraform-aws-infra/modules/ec2/)

**Purpose:** Creates EC2 instances with launch templates, monitoring, and EBS.

**Resources Created:**
- Launch Template (reusable for ASG)
- EC2 Instances (optional)
- Elastic IPs (optional)
- Enhanced CloudWatch monitoring
- EBS volumes with encryption

**Best Practices:**
✅ Use Launch Templates (not Launch Configurations)
✅ Enable detailed CloudWatch metrics
✅ Use SSM Session Manager (no SSH keys)
✅ Enable EBS optimization for production
✅ Encrypt EBS volumes

**Key Inputs:**
| Input | Type | Default | Purpose |
|-------|------|---------|---------|
| `instance_type` | string | `t3.micro` | EC2 type |
| `ami_id` | string | - | AMI ID |
| `root_volume_size` | number | `30` | EBS size (GB) |
| `enable_monitoring` | bool | `true` | CloudWatch metrics |

**Usage Guide:**
See [EC2 Module README](terraform-aws-infra/modules/ec2/README.md)

---

### ASG Module

**Location:** [terraform-aws-infra/modules/asg/](terraform-aws-infra/modules/asg/)

**Purpose:** Creates Auto Scaling Groups for dynamic instance scaling.

**Resources Created:**
- Auto Scaling Group
- Launch Template integration
- Scaling policies (target tracking or step)
- CloudWatch metrics

**Scaling Strategies:**
- Target Tracking: CPU-based auto-scaling
- Step Scaling: Multiple thresholds
- Scheduled Scaling: Time-based

**Key Inputs:**
| Input | Type | Default | Purpose |
|-------|------|---------|---------|
| `min_size` | number | `1` | Minimum instances |
| `max_size` | number | `3` | Maximum instances |
| `desired_capacity` | number | `2` | Target instance count |
| `health_check_type` | string | `ELB` | ELB or EC2 |

**Usage Guide:**
See [ASG Module README](terraform-aws-infra/modules/asg/README.md)

---

### ALB Module

**Location:** [terraform-aws-infra/modules/alb/](terraform-aws-infra/modules/alb/)

**Purpose:** Creates Application Load Balancer for Layer 7 routing.

**Resources Created:**
- Application Load Balancer
- Target Groups
- Listeners (HTTP/HTTPS)
- Access logs to S3
- CloudWatch alarms

**Layer 7 Routing:** Route by path, hostname, HTTP method

**Key Features:**
✅ HTTPS with ACM certificate
✅ Access logging for compliance
✅ Health checks with custom paths
✅ Multi-AZ for high availability

**Key Inputs:**
| Input | Type | Default | Purpose |
|-------|------|---------|---------|
| `enable_https` | bool | `true` | HTTPS listener |
| `certificate_arn` | string | - | ACM certificate |
| `enable_access_logs` | bool | `false` | S3 logging |

**Usage Guide:**
See [ALB Module README](terraform-aws-infra/modules/alb/README.md)

---

### NLB Module

**Location:** [terraform-aws-infra/modules/nlb/](terraform-aws-infra/modules/nlb/)

**Purpose:** Creates Network Load Balancer for ultra-high performance.

**Use Cases:**
- Extreme performance (millions of requests/sec)
- Low latency (ultra-low)
- Non-HTTP protocols (TCP/UDP)
- Gaming, IoT, real-time

**Key Difference from ALB:**
- Layer 4 (transport) vs Layer 7 (application)
- TCP/UDP vs HTTP/HTTPS
- 1M+ RPS vs 100K+ RPS

**Usage Guide:**
See [NLB Module README](terraform-aws-infra/modules/nlb/README.md)

---

### Route53 Module

**Location:** [terraform-aws-infra/modules/route53/](terraform-aws-infra/modules/route53/)

**Purpose:** Creates DNS records and health checks.

**Resources Created:**
- Hosted Zone
- DNS records (A, AAAA, CNAME, MX)
- Health checks
- Routing policies

**Routing Policies:**
- Simple: Default
- Weighted: Percentage-based routing
- Latency: Lowest latency
- Failover: Active-passive

**Usage Guide:**
See [Route53 Module README](terraform-aws-infra/modules/route53/README.md)

---

### Databases Module (RDS)

**Location:** [terraform-aws-infra/modules/databases/](terraform-aws-infra/modules/databases/)

**Purpose:** Creates managed RDS instances for MySQL, PostgreSQL, MariaDB.

**Environment Defaults:**

**Development:**
- Instance: `db.t3.micro` (burstable)
- Storage: 20-100 GB
- Multi-AZ: false (cost savings)
- Backups: 7 days

**Production:**
- Instance: `db.r5.large` (memory-optimized)
- Storage: 500+ GB
- Multi-AZ: true (high availability)
- Backups: 30+ days

**Key Features:**
✅ Automated backups
✅ Multi-AZ failover
✅ KMS encryption
✅ Enhanced monitoring

**Usage Guide:**
See [Databases Module README](terraform-aws-infra/modules/databases/README.md)

---

### Aurora Module

**Location:** [terraform-aws-infra/modules/aurora/](terraform-aws-infra/modules/aurora/)

**Purpose:** Creates managed Aurora MySQL/PostgreSQL clusters.

**Benefits over RDS:**
- 5x faster reads
- Auto-scaling replicas
- Better availability
- Faster recovery

**Resources Created:**
- Aurora Cluster
- Primary instance
- Read replicas (auto-created per AZ)
- Cluster Parameter Group

**Usage Guide:**
See [Aurora Module README](terraform-aws-infra/modules/aurora/README.md)

---

### ElastiCache Module

**Location:** [terraform-aws-infra/modules/elasticache/](terraform-aws-infra/modules/elasticache/)

**Purpose:** Creates Redis or Memcached for in-memory caching.

**Redis vs Memcached:**
- Redis: Persistence, replication, advanced data structures
- Memcached: Simple cache, higher throughput

**Use Cases:**
- Session storage
- Cache layer (database query results)
- Real-time leaderboards
- Rate limiting

**Key Inputs:**
| Input | Type | Default | Purpose |
|-------|------|---------|---------|
| `engine` | string | `redis` | redis or memcached |
| `node_type` | string | `cache.t3.micro` | Cache node type |
| `num_cache_nodes` | number | `1` | Number of nodes |

**Usage Guide:**
See [ElastiCache Module README](terraform-aws-infra/modules/elasticache/README.md)

---

### DynamoDB Module

**Location:** [terraform-aws-infra/modules/dynamodb/](terraform-aws-infra/modules/dynamodb/)

**Purpose:** Creates NoSQL DynamoDB tables.

**Billing Modes:**

**On-Demand (PAY_PER_REQUEST):**
- Good for: Unpredictable workloads
- Auto-scaling: Yes
- Cost: $1.25 per million read units

**Provisioned:**
- Good for: Predictable workloads
- Manual scaling required
- Cost: Cheaper for consistent traffic

**Key Features:**
✅ Global Secondary Indexes
✅ TTL (auto-delete old records)
✅ DynamoDB Streams
✅ Point-in-time recovery

**Usage Guide:**
See [DynamoDB Module README](terraform-aws-infra/modules/dynamodb/README.md)

---

### Lambda Module

**Location:** [terraform-aws-infra/modules/lambda/](terraform-aws-infra/modules/lambda/)

**Purpose:** Creates serverless Lambda functions.

**Runtimes Supported:**
- Python 3.11
- Node.js 18.x, 20.x
- Go 1.x
- Java 17, 21
- .NET 8

**Key Features:**
✅ VPC integration
✅ Environment variables
✅ Reserved concurrency
✅ CloudWatch Logs

**Best Practices:**
✅ Use environment variables (not hardcoded)
✅ Set reserved concurrency
✅ Higher memory = faster CPU
✅ Use VPC only when needed

**Usage Guide:**
See [Lambda Module README](terraform-aws-infra/modules/lambda/README.md)

---

### Secrets Manager Module

**Location:** [terraform-aws-infra/modules/secrets/](terraform-aws-infra/modules/secrets/)

**Purpose:** Stores encrypted secrets (passwords, API keys, tokens).

**Use Cases:**
- Database passwords
- API keys
- OAuth tokens
- Certificate contents

**Naming Convention:**
```
/myapp/dev/db/password
/myapp/dev/github/token
/myapp/prod/api/key
/myapp/prod/oauth/secret
```

**Features:**
✅ KMS encryption
✅ Automatic rotation
✅ Audit logging
✅ Version tracking

**Usage Guide:**
See [Secrets Manager Module README](terraform-aws-infra/modules/secrets/README.md)

---

### KMS Module

**Location:** [terraform-aws-infra/modules/kms/](terraform-aws-infra/modules/kms/)

**Purpose:** Creates KMS encryption keys for all services.

**Encrypted Resources:**
- Secrets Manager
- RDS databases
- S3 buckets
- EBS volumes
- DynamoDB

**Best Practices:**
✅ Enable auto-rotation
✅ Separate keys per environment
✅ CloudTrail audit logging
✅ Multi-region replication for DR

**Usage Guide:**
See [KMS Module README](terraform-aws-infra/modules/kms/README.md)

---

### ECS Module

**Location:** [terraform-aws-infra/modules/ecs/](terraform-aws-infra/modules/ecs/)

**Purpose:** Creates ECS cluster for container orchestration.

**Launch Types:**
- EC2: Manage instances yourself
- Fargate: Serverless containers
- FARGATE_SPOT: Discounted Fargate

**Features:**
✅ CloudWatch Container Insights
✅ Auto Scaling
✅ Service discovery
✅ Task placement strategies

**Usage Guide:**
See [ECS Module README](terraform-aws-infra/modules/ecs/README.md)

---

### Monitoring Module

**Location:** [terraform-aws-infra/modules/monitoring/](terraform-aws-infra/modules/monitoring/)

**Purpose:** Creates CloudWatch dashboards and alarms.

**Resources Created:**
- Custom dashboards
- CPU/Memory/Disk alarms
- SNS notifications
- Log groups
- Metric filters

**Usage Guide:**
See [Monitoring Module README](terraform-aws-infra/modules/monitoring/README.md)

---

## Environment-Specific Configuration

Each environment (dev/stage/prod) inherits all modules with environment-specific variables:

### Development (`environments/dev/`)
- Small instance types (t3.micro, t3.small)
- Single AZ (cost savings)
- 1-2 ASG instances
- Short backup retention (7 days)
- Development SGs (broad CIDR)

### Staging (`environments/stage/`)
- Medium instance types (t3.medium)
- 2 AZs (high availability)
- 2-4 ASG instances
- 14-day backup retention
- Restricted SGs (IP-based)

### Production (`environments/prod/`)
- Large instance types (r5.large+)
- Multi-AZ (minimum 3 AZs)
- 3-10 ASG instances
- 30+ day backup retention
- Restrictive SGs (least privilege)
- Enhanced monitoring

---

## Module Enablement Strategy

**All modules are DISABLED by default** with `create = false`.

To enable a module:

```hcl
module "my_service" {
  create = true
  # Other configuration...
}
```

This approach ensures:
✅ No accidental resource creation
✅ Cost control
✅ Phased deployment
✅ Safe testing

---

## Tagging Strategy

All resources automatically tagged with:

```hcl
Environment = "dev|stage|prod"
Project     = "my-app"
Owner       = "platform-team"
CostCenter  = "engineering"
CreatedAt   = timestamp
```

Use for:
- Cost allocation
- Resource organization
- Compliance tracking
- Lifecycle policies

---

## Next Steps

1. **Deploy Backend:** Follow [Backend README](terraform-aws-infra/backend/README.md)
2. **Initialize Environments:** Connect to remote state
3. **Enable Modules:** Start with Phase 1 (VPC, IAM, SGs)
4. **Test Plan:** `terraform plan` without apply
5. **Scale Incrementally:** Add modules gradually

For detailed deployment instructions, see [Main README](README.md).
