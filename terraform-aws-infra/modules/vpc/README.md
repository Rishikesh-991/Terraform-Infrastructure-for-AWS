# VPC Module

## Overview

Complete Virtual Private Cloud (VPC) infrastructure module providing:
- Multi-AZ VPC with public and private subnets
- Internet Gateway for public access
- NAT Gateways for private subnet internet access
- VPC Flow Logs for monitoring and troubleshooting
- VPC Endpoints for AWS service access
- Security groups with sensible defaults

## Architecture

```
┌─────────────────────────────────────┐
│          VPC (10.0.0.0/16)          │
├─────────────────────────────────────┤
│ Public Subnets (3 AZs)              │
│ ├─ AZ-1: 10.0.0.0/19 + IGW          │
│ ├─ AZ-2: 10.0.32.0/19 + IGW         │
│ └─ AZ-3: 10.0.64.0/19 + IGW         │
├─────────────────────────────────────┤
│ Private Subnets (3 AZs)             │
│ ├─ AZ-1: 10.0.128.0/19 + NAT-1      │
│ ├─ AZ-2: 10.0.160.0/19 + NAT-2      │
│ └─ AZ-3: 10.0.192.0/19 + NAT-3      │
├─────────────────────────────────────┤
│ VPC Endpoints                       │
│ ├─ S3 Gateway Endpoint              │
│ └─ DynamoDB Gateway Endpoint        │
└─────────────────────────────────────┘
```

## Features

✅ **Multi-AZ Design**
- Spans 3 availability zones by default
- Redundant NAT gateways in each AZ
- High availability for critical workloads

✅ **Network Segmentation**
- Public subnets for load balancers, NAT gateways
- Private subnets for applications, databases
- Network ACLs for additional security

✅ **Monitoring**
- VPC Flow Logs capture all network traffic
- CloudWatch integration for analysis
- Helps troubleshoot connectivity issues

✅ **Cost Optimization**
- VPC Endpoints reduce data transfer costs
- Configurable flow log retention
- Efficient subnet sizing with CIDR calculation

✅ **Security**
- Default security group denies inbound
- Private subnets isolated from internet
- Outbound NAT only (not ingress)

## Usage

### Basic Deployment

```hcl
module "vpc" {
  source = "./modules/vpc"

  environment                  = "dev"
  vpc_cidr_block              = "10.0.0.0/16"
  number_of_availability_zones = 3

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

### Custom Configuration

```hcl
module "vpc" {
  source = "./modules/vpc"

  environment                    = "prod"
  vpc_cidr_block                = "10.0.0.0/16"
  number_of_availability_zones   = 3
  public_subnet_bits            = 4
  private_subnet_bits           = 4
  vpc_flow_logs_retention       = 90
  vpc_flow_logs_traffic_type    = "REJECT"
  create_network_acls           = true
  create_s3_endpoint            = true
  create_dynamodb_endpoint      = true

  tags = {
    Environment = "prod"
    Project     = "enterprise"
    CostCenter  = "Engineering"
  }
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | VPC ID |
| `vpc_cidr_block` | VPC CIDR block |
| `public_subnet_ids` | Public subnet IDs |
| `private_subnet_ids` | Private subnet IDs |
| `nat_gateway_ids` | NAT Gateway IDs |
| `internet_gateway_id` | IGW ID |
| `vpc_summary` | Complete VPC configuration summary |

## Costs

**Typical Monthly Costs (dev environment):**
- VPC: FREE
- NAT Gateways (3): $32.40 ($0.45/hour each)
- Data transfer: ~$5-10 (depending on usage)
- VPC Flow Logs: ~$5

**Total: ~$45-50/month**

**Cost Optimization Tips:**
- Use fewer AZs in non-production (2 instead of 3)
- Enable VPC endpoints to save on NAT data transfer
- Reduce flow log retention for non-prod

## Advanced Topics

### Adding Routes

```hcl
resource "aws_route" "peering" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.example.id
}
```

### Connecting to On-Premises

```hcl
resource "aws_vpn_gateway" "example" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_customer_gateway" "office" {
  bgp_asn    = 65000
  ip_address = "203.0.113.12"  # Your office public IP
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "office" {
  vpn_gateway_id      = aws_vpn_gateway.example.id
  customer_gateway_id = aws_customer_gateway.office.id
  type                = "ipsec.1"
  static_routes_only  = true
}
```

### VPC Peering

```hcl
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = module.vpc.vpc_id
  peer_vpc_id   = aws_vpc.peer.id
  auto_accept   = true
}
```

## Troubleshooting

### Instances Can't Reach Internet

1. Check security group allows outbound on port 443/80
2. Verify NAT gateway is running: `aws ec2 describe-nat-gateways`
3. Check private route table: `aws ec2 describe-route-tables`

### High Data Transfer Costs

1. Enable S3 VPC Endpoint: `create_s3_endpoint = true`
2. Enable DynamoDB VPC Endpoint: `create_dynamodb_endpoint = true`
3. Use interface endpoints for other services

### VPC Flow Logs Missing Data

1. Check IAM role has CloudLogs permissions
2. Verify flow log destination exists
3. Check VPC Flow Logs status: `aws ec2 describe-flow-logs`

## References

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-best-practices.html)
- [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)
- [VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/)

## Next Steps

1. ✅ VPC created
2. ➡️ Deploy security groups for specific services
3. ➡️ Deploy EC2 instances in public/private subnets
4. ➡️ Configure VPN/Direct Connect for on-premises connectivity
