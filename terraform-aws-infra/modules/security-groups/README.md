# Security Groups Module

**Purpose:** Creates network security groups for ALB/NLB, EC2 applications, and databases.

## What It Creates

- **Bastion Security Group:** For SSH access via SSM Session Manager
- **Application Security Group:** For web traffic (HTTP/HTTPS)
- **Database Security Group:** For database traffic (MySQL/PostgreSQL/Aurora)

## Architecture

```
Internet
   │
   ├─→ [ALB/NLB SG] (80, 443)
   │       │
   └─→ [EC2 App SG] (80, 443 from ALB)
           │
           └─→ [RDS SG] (3306 from App)

Admin
   │
   └─→ [Bastion SG] (22 SSM Session Manager)
           │
           └─→ [RDS SG] (via Bastion port forwarding)
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `environment` | string | - | Environment name |
| `vpc_id` | string | - | VPC ID to place SGs |
| `management_cidrs` | list(string) | `["0.0.0.0/0"]` | CIDRs allowed for SSH/management |
| `alb_allowed_cidrs` | list(string) | `["0.0.0.0/0"]` | CIDRs allowed for HTTP/HTTPS |
| `db_port` | number | `5432` | Database port (3306=MySQL, 5432=PostgreSQL) |
| `tags` | map(string) | `{}` | Tags for all SGs |

## Outputs

| Name | Description |
|------|-------------|
| `bastion_sg_id` | Bastion security group ID |
| `app_sg_id` | Application security group ID |
| `db_sg_id` | Database security group ID |

## Usage Example

```hcl
module "security_groups" {
  source = "../../modules/security-groups"

  environment       = "prod"
  vpc_id            = module.vpc.vpc_id
  management_cidrs  = ["203.0.113.0/24"]  # Your office CIDR
  alb_allowed_cidrs = ["0.0.0.0/0"]       # Public internet
  db_port           = 5432                 # PostgreSQL

  tags = {
    Environment = "prod"
    Project     = "my-app"
  }
}

# Use in EC2 launch template
module "ec2" {
  security_group_ids = [module.security_groups.app_sg_id]
}

# Use in RDS
module "rds" {
  vpc_security_group_ids = [module.security_groups.db_sg_id]
}
```

## Default Rules

### Bastion SG
- **Inbound:** 22/TCP from management_cidrs (for SSM Session Manager)
- **Outbound:** All traffic

### Application SG
- **Inbound:** 80/TCP, 443/TCP from alb_allowed_cidrs
- **Inbound:** 80/TCP, 443/TCP from self (for ASG communication)
- **Outbound:** All traffic (to databases, internet, services)

### Database SG
- **Inbound:** db_port from app_sg_id only
- **Outbound:** None (databases only receive, don't initiate)

## Principle: Least Privilege

✅ Database SG denies all outbound traffic  
✅ Application SG restricted to specific ports from ALB  
✅ Bastion SG restricted to management CIDRs  
✅ All ingress rules explicitly white-listed  

## Phase

**Phase 1** — Security Foundation
