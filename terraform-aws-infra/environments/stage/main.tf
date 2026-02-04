# ============================================================================
# DEV ENVIRONMENT - Main Configuration
# ============================================================================
# Development environment infrastructure using shared modules
# Lower redundancy, faster iteration, cost-optimized
# ============================================================================

module "vpc" {
  source = "../../modules/vpc"

  environment                  = var.environment
  vpc_cidr_block              = var.vpc_cidr_block
  number_of_availability_zones = var.number_of_availability_zones
  public_subnet_bits          = var.public_subnet_bits
  private_subnet_bits         = var.private_subnet_bits
  vpc_flow_logs_retention     = var.vpc_flow_logs_retention
  vpc_flow_logs_traffic_type  = var.vpc_flow_logs_traffic_type
  create_s3_endpoint          = var.create_s3_endpoint
  create_dynamodb_endpoint    = var.create_dynamodb_endpoint

  tags = merge(
    var.common_tags,
    {
      Module = "vpc"
    }
  )
}

module "iam" {
  source = "../../modules/iam"

  environment               = var.environment
  create_cross_env_role     = var.create_cross_env_role
  create_cross_account_role = var.create_cross_account_role
  trusted_account_id        = var.trusted_account_id
  external_id               = var.external_id

  tags = merge(
    var.common_tags,
    {
      Module = "iam"
    }
  )
}
