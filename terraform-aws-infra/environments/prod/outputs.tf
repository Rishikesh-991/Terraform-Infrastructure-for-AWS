# ============================================================================
# OUTPUTS - Development Environment
# ============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ips" {
  description = "NAT Gateway Elastic IPs"
  value       = module.vpc.nat_gateway_ips
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = module.iam.ec2_instance_profile_name
}

output "application_role_arn" {
  description = "Application role ARN"
  value       = module.iam.application_role_arn
}

output "lambda_execution_role_arn" {
  description = "Lambda execution role ARN"
  value       = module.iam.lambda_execution_role_arn
}

output "infrastructure_summary" {
  description = "Complete infrastructure summary"
  value = {
    vpc              = module.vpc.vpc_summary
    iam_roles        = module.iam.iam_roles_summary
    environment      = var.environment
    region           = var.aws_region
    availability_zones = module.vpc.availability_zones
  }
}
