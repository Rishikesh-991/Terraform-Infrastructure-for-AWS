# Databases Module (RDS/Aurora)

**Purpose:** Creates managed relational databases (MySQL, PostgreSQL, Aurora) with high availability and backups.

## What It Creates

- **RDS Instance / Aurora Cluster:** Managed database
- **DB Subnet Group:** For placement across AZs
- **DB Parameter Group:** For database configuration
- **Security Groups:** For database access
- **Backups:** Automated snapshots with retention
- **Monitoring:** Enhanced monitoring with CloudWatch
- **Encryption:** KMS encryption at rest

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable database creation |
| `environment` | string | - | Environment name |
| `engine` | string | `postgres` | Database engine (mysql, postgres, aurora-mysql, aurora-postgresql) |
| `engine_version` | string | `15.3` | Database version |
| `instance_class` | string | `db.t3.micro` | Instance type (dev: micro, prod: large/xlarge) |
| `allocated_storage` | number | `100` | Storage size (GB) |
| `db_name` | string | `appdb` | Database name |
| `username` | string | `admin` | Master username |
| `password` | string | - | Master password (use Secrets Manager) |
| `multi_az` | bool | `true` | Enable multi-AZ (prod: true, dev: false) |
| `backup_retention_period` | number | `30` | Backup retention (days) |
| `backup_window` | string | `03:00-04:00` | Daily backup window |
| `maintenance_window` | string | `mon:04:00-mon:05:00` | Maintenance window |
| `skip_final_snapshot` | bool | `true` | Skip snapshot on deletion (dev: true, prod: false) |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `db_instance_id` | Database instance ID |
| `db_instance_endpoint` | Database endpoint (hostname:port) |
| `db_instance_port` | Database port |
| `db_instance_resource_id` | Resource ID for backups |
| `db_subnet_group_name` | DB subnet group name |

## Usage Example

```hcl
module "databases" {
  source = "../../modules/databases"

  create                 = true
  environment            = "prod"
  engine                 = "postgres"
  engine_version         = "15.3"
  instance_class         = "db.r5.large"  # prod: r5.large, dev: t3.micro
  allocated_storage      = 500
  db_name                = "myapp"
  username               = "dbadmin"
  password               = data.aws_secretsmanager_secret_version.db_password.secret_string
  multi_az               = true
  backup_retention_period = 30
  skip_final_snapshot    = false

  tags = {
    Environment = "prod"
  }
}

# Use with RDS endpoint in application config
resource "aws_ssm_parameter" "db_endpoint" {
  name  = "/myapp/prod/db/endpoint"
  value = module.databases.db_instance_endpoint
  type  = "String"
}
```

## Environment-Specific Settings

### Development
- Instance: `db.t3.micro` (burstable, cost-effective)
- Storage: 20-100 GB
- Multi-AZ: false (cost savings)
- Backups: 7 days
- Snapshots: Delete on termination

### Production
- Instance: `db.r5.large` or higher (memory-optimized)
- Storage: 500+ GB
- Multi-AZ: true (high availability)
- Backups: 30+ days
- Snapshots: Keep for compliance

## Disaster Recovery

### Backup Strategy

```bash
# List snapshots
aws rds describe-db-snapshots --db-instance-identifier myapp-prod

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier myapp-prod-restore \
  --db-snapshot-identifier myapp-prod-backup-2024-01-15
```

## Phase

**Phase 2** — Databases
