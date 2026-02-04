# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "enterprise"
}

# ============================================================================
# VPC VARIABLES
# ============================================================================

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "number_of_availability_zones" {
  description = "Number of availability zones (dev: 2, prod: 3)"
  type        = number
  default     = 2
}

variable "public_subnet_bits" {
  description = "Public subnet bits"
  type        = number
  default     = 3
}

variable "private_subnet_bits" {
  description = "Private subnet bits"
  type        = number
  default     = 3
}

variable "vpc_flow_logs_retention" {
  description = "VPC Flow Logs retention in days (dev: 7, prod: 30)"
  type        = number
  default     = 7
}

variable "vpc_flow_logs_traffic_type" {
  description = "VPC Flow Logs traffic type"
  type        = string
  default     = "REJECT"
}

variable "create_s3_endpoint" {
  description = "Create S3 VPC endpoint"
  type        = bool
  default     = true
}

variable "create_dynamodb_endpoint" {
  description = "Create DynamoDB VPC endpoint"
  type        = bool
  default     = true
}

# ============================================================================
# IAM VARIABLES
# ============================================================================

variable "create_cross_env_role" {
  description = "Create cross-environment role"
  type        = bool
  default     = true
}

variable "create_cross_account_role" {
  description = "Create cross-account role"
  type        = bool
  default     = false
}

variable "trusted_account_id" {
  description = "Trusted AWS account ID"
  type        = string
  default     = ""
}

variable "external_id" {
  description = "External ID for cross-account access"
  type        = string
  default     = ""
  sensitive   = true
}

# ============================================================================
# TAGGING
# ============================================================================

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "enterprise"
    Owner       = "DevOps"
    CostCenter  = "Engineering"
  }
}
