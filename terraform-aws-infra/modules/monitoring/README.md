# Monitoring Module

**Purpose:** Creates CloudWatch dashboards, alarms, and SNS notifications for infrastructure monitoring.

## What It Creates

- **CloudWatch Dashboard:** Visual metrics display
- **CloudWatch Alarms:** CPU, memory, disk, network alerts
- **SNS Topics:** For alert notifications
- **CloudWatch Log Groups:** Centralized logging
- **Metric Filters:** Extract metrics from logs

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable monitoring |
| `environment` | string | - | Environment name |
| `sns_email` | string | - | Email for notifications |
| `alarm_threshold_cpu` | number | `80` | CPU % threshold |
| `alarm_threshold_memory` | number | `85` | Memory % threshold |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `dashboard_url` | CloudWatch dashboard URL |
| `sns_topic_arn` | SNS topic ARN for alerts |

## Phase

**Phase 2** — Observability
