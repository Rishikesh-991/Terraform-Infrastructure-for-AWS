# Aurora Module

**Purpose:** Creates AWS Aurora MySQL/PostgreSQL clusters with multi-AZ replication and read replicas.

## What It Creates

- **Aurora Cluster:** Primary + read replicas across AZs
- **Cluster Parameter Group:** Database configuration
- **Cluster Subnet Group:** Multi-AZ placement
- **Enhanced Monitoring:** Performance Insights integration

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable Aurora |
| `cluster_identifier` | string | - | Cluster name |
| `engine` | string | `aurora-postgresql` | aurora-mysql or aurora-postgresql |
| `engine_version` | string | `15.2` | Engine version |
| `database_name` | string | `myapp` | Database name |
| `master_username` | string | `admin` | Master username |
| `master_password` | string | - | Master password |
| `backup_retention_period` | number | `7` | Backup retention (days) |
| `preferred_backup_window` | string | `03:00-04:00` | Backup window |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | Cluster ID |
| `cluster_endpoint` | Primary endpoint |
| `reader_endpoint` | Read-only endpoint |

## Phase

**Phase 3** — Managed Database
