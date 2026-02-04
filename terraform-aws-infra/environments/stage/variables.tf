# ============================================================================
# STAGE ENVIRONMENT VARIABLES
# ============================================================================
# Staging: Pre-production testing with moderate redundancy
# Cost-optimized but production-like configuration
# ============================================================================

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "stage"
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
# VPC VARIABLES - More redundant than dev, less than prod
# ============================================================================

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.1.0.0/16"
}

variable "number_of_availability_zones" {
  description = "Number of availability zones (stage: 2-3)"
  type        = number
  default     = 2
}

variable "public_subnet_bits" {
  type    = number
  default = 3
}

variable "private_subnet_bits" {
  type    = number
  default = 3
}

variable "vpc_flow_logs_retention" {
  description = "VPC Flow Logs retention in days"
  type        = number
  default     = 14
}

variable "vpc_flow_logs_traffic_type" {
  type    = string
  default = "ALL"
}

variable "create_s3_endpoint" {
  type    = bool
  default = true
}

variable "create_dynamodb_endpoint" {
  type    = bool
  default = true
}

# ============================================================================
# IAM VARIABLES
# ============================================================================

variable "create_cross_env_role" {
  type    = bool
  default = true
}

variable "create_cross_account_role" {
  type    = bool
  default = false
}

variable "trusted_account_id" {
  type    = string
  default = ""
}

variable "external_id" {
  type      = string
  default   = ""
  sensitive = true
}

# ============================================================================
# TAGGING
# ============================================================================

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "stage"
    Project     = "enterprise"
    Owner       = "DevOps"
    CostCenter  = "Engineering"
  }
}
