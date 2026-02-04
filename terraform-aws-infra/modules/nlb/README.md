# NLB Module (Network Load Balancer)

**Purpose:** Creates a Network Load Balancer for ultra-high performance, low-latency load balancing.

## What It Creates

- **Network Load Balancer:** Layer 4 (transport) load balancing
- **Target Groups:** For TCP/UDP traffic
- **Listeners:** Protocol and port configuration
- **Security Groups:** Inbound/outbound rules

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable NLB |
| `name` | string | - | NLB name |
| `vpc_id` | string | - | VPC ID |
| `subnets` | list(string) | `[]` | Subnet IDs |
| `load_balancer_type` | string | `network` | network or gateway |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `nlb_id` | NLB ID |
| `nlb_dns_name` | NLB DNS name |
| `nlb_zone_id` | Zone ID for Route53 alias |

## Phase

**Phase 2** — Ultra-High Performance Load Balancing
