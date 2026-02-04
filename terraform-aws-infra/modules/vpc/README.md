# VPC Module

**Purpose:** Creates a production-grade Virtual Private Cloud with multi-AZ networking, subnets, gateways, and endpoints.

## What It Creates

- **VPC:** With custom CIDR block
- **Public Subnets:** One per AZ, with route to Internet Gateway
- **Private Subnets:** One per AZ, with route to NAT Gateways (outbound internet)
- **Internet Gateway:** For public subnet internet access
- **NAT Gateways:** For private subnet outbound internet access
- **Elastic IPs:** One per NAT Gateway
- **Route Tables:** Separate for public and private traffic
- **VPC Flow Logs:** For network traffic analysis
- **VPC Endpoints:** S3 and DynamoDB gateways (cost optimization)

## Architecture

```
VPC (10.0.0.0/16)
├── AZ-1
│   ├── Public Subnet (10.0.1.0/24) → IGW
│   └── Private Subnet (10.0.2.0/24) → NAT Gateway
├── AZ-2
│   ├── Public Subnet (10.0.3.0/24) → IGW
│   └── Private Subnet (10.0.4.0/24) → NAT Gateway
└── Gateway Endpoints
    ├── S3
    └── DynamoDB
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `environment` | string | - | Environment name (dev/stage/prod) |
| `vpc_cidr_block` | string | `10.0.0.0/16` | CIDR for VPC |
| `number_of_availability_zones` | number | `2` | Number of AZs to use |
| `public_subnet_bits` | number | `4` | CIDR block size for public subnets |
| `private_subnet_bits` | number | `4` | CIDR block size for private subnets |
| `vpc_flow_logs_retention` | number | `7` | CloudWatch log retention (days) |
| `vpc_flow_logs_traffic_type` | string | `ACCEPT` | Log accepted or all traffic |
| `create_s3_endpoint` | bool | `true` | Create S3 gateway endpoint |
| `create_dynamodb_endpoint` | bool | `true` | Create DynamoDB gateway endpoint |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `vpc_cidr_block` | VPC CIDR block |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `internet_gateway_id` | Internet Gateway ID |
| `nat_gateway_ids` | List of NAT Gateway IDs |
| `nat_gateway_ips` | Elastic IPs of NAT Gateways |
| `public_route_table_ids` | Public route table IDs |
| `private_route_table_ids` | Private route table IDs |
| `vpc_summary` | Complete VPC summary object |

## Usage Example

```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment                  = "dev"
  vpc_cidr_block              = "10.0.0.0/16"
  number_of_availability_zones = 2
  public_subnet_bits          = 4
  private_subnet_bits         = 4
  vpc_flow_logs_retention     = 7

  tags = {
    Environment = "dev"
    Project     = "my-app"
    Owner       = "platform-team"
  }
}

# Use outputs in other modules
module "security_groups" {
  vpc_id = module.vpc.vpc_id
}

module "rds" {
  subnet_ids = module.vpc.private_subnet_ids
}
```

## Key Features

✅ **Multi-AZ:** Automatic public and private subnets per AZ  
✅ **High Availability:** NAT Gateway in each AZ  
✅ **Monitoring:** VPC Flow Logs for network analysis  
✅ **Cost Optimization:** S3 & DynamoDB endpoints save data transfer costs  
✅ **Tagging:** Automatic Environment and Project tags  

## Network Flow

### Public Subnet (Inbound)
1. Internet traffic → IGW → Public Subnet
2. Public instances can have Elastic IPs

### Private Subnet (Outbound)
1. Private instances → NAT Gateway → IGW → Internet
2. Return traffic comes back through NAT

## Customization

### Add More Availability Zones

```hcl
number_of_availability_zones = 3
```

### Disable Endpoints

```hcl
create_s3_endpoint       = false
create_dynamodb_endpoint = false
```

### Change VPC Size

```hcl
vpc_cidr_block = "10.1.0.0/16"  # Larger VPC
```

## Phase

**Phase 1** — Networking Foundation
