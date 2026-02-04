output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnets_cidr" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnets_cidr" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_ips" {
  description = "List of Elastic IPs for NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private[*].id
}

output "default_security_group_id" {
  description = "Default security group ID"
  value       = aws_default_security_group.default.id
}

output "vpc_flow_logs_group_name" {
  description = "CloudWatch Log Group for VPC Flow Logs"
  value       = aws_flow_log_group.vpc_flow_logs.name
}

output "s3_vpc_endpoint_id" {
  description = "S3 VPC Endpoint ID"
  value       = try(aws_vpc_endpoint.s3[0].id, null)
}

output "dynamodb_vpc_endpoint_id" {
  description = "DynamoDB VPC Endpoint ID"
  value       = try(aws_vpc_endpoint.dynamodb[0].id, null)
}

output "availability_zones" {
  description = "List of availability zones"
  value       = data.aws_availability_zones.available.names
}

output "vpc_summary" {
  description = "Summary of VPC configuration"
  value = {
    vpc_id                = aws_vpc.main.id
    cidr_block            = aws_vpc.main.cidr_block
    public_subnets        = aws_subnet.public[*].id
    private_subnets       = aws_subnet.private[*].id
    nat_gateways          = aws_nat_gateway.main[*].id
    internet_gateway      = aws_internet_gateway.main.id
    availability_zones    = data.aws_availability_zones.available.names
    default_security_group = aws_default_security_group.default.id
  }
}
