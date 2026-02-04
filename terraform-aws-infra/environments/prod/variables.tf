# ============================================================================
# PRODUCTION ENVIRONMENT VARIABLES
# ============================================================================
# Production: Enterprise-grade with maximum redundancy and monitoring
# Cost secondary to reliability and performance
# ============================================================================

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
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
# VPC VARIABLES - Maximum redundancy and monitoring
# ============================================================================

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.2.0.0/16"
}

variable "number_of_availability_zones" {
  description = "Number of availability zones (prod: 3)"
  type        = number
  default     = 3
}

variable "public_subnet_bits" {
  type    = number
  default = 4
}

variable "private_subnet_bits" {
  type    = number
  default = 4
}

variable "vpc_flow_logs_retention" {
  description = "VPC Flow Logs retention in days (prod: 30)"
  type        = number
  default     = 30
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
  description = "Create cross-account role for audit/compliance"
  type        = bool
  default     = false
}

variable "trusted_account_id" {
  description = "Audit account ID for cross-account access"
  type        = string
  default     = ""
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
    Environment = "prod"
    Project     = "enterprise"
    Owner       = "DevOps"
    CostCenter  = "Engineering"
    Criticality = "high"
  }
}
