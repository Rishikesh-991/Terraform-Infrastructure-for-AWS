# ============================================================================
# VPC MODULE - Network Foundation
# ============================================================================
# 
# Creates complete VPC infrastructure including:
# - VPC with configurable CIDR block
# - Public subnets (NAT gateways, bastion hosts)
# - Private subnets (applications, databases)
# - Internet Gateway for public access
# - NAT Gateways for private subnet outbound access
# - Route tables and associations
# - Network ACLs
# - VPC Flow Logs for monitoring
# - VPC Endpoints for service access
#
# This module follows AWS best practices:
# - Multi-AZ deployment for high availability
# - Separated public and private subnets
# - Redundant NAT gateways in each AZ
# - VPC Flow Logs for troubleshooting
# ============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ============================================================================
# VPC
# ============================================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpc"
    }
  )
}

# Enable VPC Flow Logs for monitoring
resource "aws_flow_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${var.environment}"
  retention_in_days = var.vpc_flow_logs_retention

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpc-flow-logs"
    }
  )
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = "${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpc-flow-logs-role"
    }
  )
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${var.environment}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_flow_log_group.vpc_flow_logs.arn}:*"
      }
    ]
  })
}

resource "aws_flow_log" "vpc" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = "${aws_flow_log_group.vpc_flow_logs.arn}:*"
  traffic_type    = var.vpc_flow_logs_traffic_type
  vpc_id          = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpc-flow-logs"
    }
  )
}

# ============================================================================
# INTERNET GATEWAY
# ============================================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-igw"
    }
  )
}

# ============================================================================
# ELASTIC IPs FOR NAT GATEWAYS
# ============================================================================
resource "aws_eip" "nat" {
  count  = var.number_of_availability_zones
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nat-eip-${count.index + 1}"
    }
  )
}

# ============================================================================
# PUBLIC SUBNETS
# ============================================================================
resource "aws_subnet" "public" {
  count                   = var.number_of_availability_zones
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, var.public_subnet_bits, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-public-subnet-${count.index + 1}"
      Type = "Public"
    }
  )
}

# ============================================================================
# PRIVATE SUBNETS
# ============================================================================
resource "aws_subnet" "private" {
  count             = var.number_of_availability_zones
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, var.private_subnet_bits, count.index + var.number_of_availability_zones)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-private-subnet-${count.index + 1}"
      Type = "Private"
    }
  )
}

# ============================================================================
# NAT GATEWAYS (One per AZ for HA)
# ============================================================================
resource "aws_nat_gateway" "main" {
  count         = var.number_of_availability_zones
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.main]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nat-${count.index + 1}"
    }
  )
}

# ============================================================================
# PUBLIC ROUTE TABLE
# ============================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-public-rt"
      Type = "Public"
    }
  )
}

resource "aws_route_table_association" "public" {
  count          = var.number_of_availability_zones
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================================================
# PRIVATE ROUTE TABLES (One per AZ for redundancy)
# ============================================================================
resource "aws_route_table" "private" {
  count  = var.number_of_availability_zones
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-private-rt-${count.index + 1}"
      Type = "Private"
    }
  )
}

resource "aws_route_table_association" "private" {
  count          = var.number_of_availability_zones
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ============================================================================
# NETWORK ACL (Optional - for added security)
# ============================================================================
resource "aws_network_acl" "private" {
  count      = var.create_network_acls ? 1 : 0
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  # Allow all outbound traffic
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Allow inbound traffic from within VPC
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 0
    to_port    = 0
  }

  # Allow ephemeral ports from internet
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-private-nacl"
    }
  )
}

# ============================================================================
# SECURITY GROUP - VPC DEFAULT
# ============================================================================
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # Deny all inbound by default
  # Allow all outbound

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-default-sg"
    }
  )
}

# ============================================================================
# VPC ENDPOINTS (S3 and DynamoDB gateway endpoints for private subnets)
# ============================================================================
resource "aws_vpc_endpoint" "s3" {
  count             = var.create_s3_endpoint ? 1 : 0
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-s3-endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "dynamodb" {
  count             = var.create_dynamodb_endpoint ? 1 : 0
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-dynamodb-endpoint"
    }
  )
}

# ============================================================================
# DATA SOURCES
# ============================================================================
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}
