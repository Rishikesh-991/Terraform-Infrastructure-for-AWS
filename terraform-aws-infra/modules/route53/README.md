# Route53 Module

**Purpose:** Creates DNS records and health checks for domain management.

## What It Creates

- **Hosted Zone:** DNS zone for domain
- **DNS Records:** A, AAAA, CNAME, MX records
- **Health Checks:** Monitor endpoint health
- **Routing Policies:** Simple, weighted, latency-based, failover

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable Route53 |
| `zone_name` | string | - | Domain name (example.com) |
| `records` | list(object) | `[]` | DNS records |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `zone_id` | Hosted Zone ID |
| `name_servers` | NS records for domain registration |

## Usage Example

```hcl
module "route53" {
  source = "../../modules/route53"

  create    = true
  zone_name = "example.com"

  tags = {
    Environment = "prod"
  }
}

# Create DNS record
resource "aws_route53_record" "app" {
  zone_id = module.route53.zone_id
  name    = "app.example.com"
  type    = "A"
  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}
```

## Phase

**Phase 2** — DNS
