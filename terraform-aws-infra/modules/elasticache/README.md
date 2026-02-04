# ElastiCache Module

**Purpose:** Creates ElastiCache clusters for Redis/Memcached in-memory caching.

## What It Creates

- **Cache Cluster / Replication Group:** Redis or Memcached cluster
- **Parameter Group:** Cache configuration
- **Subnet Group:** Multi-AZ placement
- **Security Groups:** Cache access control

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable ElastiCache |
| `cluster_id` | string | - | Cluster identifier |
| `engine` | string | `redis` | redis or memcached |
| `engine_version` | string | `7.0` | Engine version |
| `node_type` | string | `cache.t3.micro` | Node type |
| `num_cache_nodes` | number | `1` | Number of nodes |
| `automatic_failover_enabled` | bool | `true` | Multi-AZ failover |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_address` | Primary node address |
| `cluster_port` | Cache port |

## Phase

**Phase 2** — Caching
