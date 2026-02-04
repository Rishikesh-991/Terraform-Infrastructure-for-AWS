variable "environment" {
  description = "Environment name (dev/stage/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, stage, or prod"
  }
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "VPC CIDR must be valid CIDR notation"
  }
}

variable "number_of_availability_zones" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3
  validation {
    condition     = var.number_of_availability_zones >= 2 && var.number_of_availability_zones <= 4
    error_message = "Must use 2-4 availability zones"
  }
}

variable "public_subnet_bits" {
  description = "Number of bits to subnet for public subnets"
  type        = number
  default     = 3
}

variable "private_subnet_bits" {
  description = "Number of bits to subnet for private subnets"
  type        = number
  default     = 3
}

variable "vpc_flow_logs_retention" {
  description = "Days to retain VPC Flow Logs"
  type        = number
  default     = 30
}

variable "vpc_flow_logs_traffic_type" {
  description = "Type of traffic to log (ACCEPT, REJECT, or ALL)"
  type        = string
  default     = "ALL"
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.vpc_flow_logs_traffic_type)
    error_message = "Traffic type must be ACCEPT, REJECT, or ALL"
  }
}

variable "create_network_acls" {
  description = "Whether to create Network ACLs"
  type        = bool
  default     = false
}

variable "create_s3_endpoint" {
  description = "Whether to create S3 gateway endpoint"
  type        = bool
  default     = true
}

variable "create_dynamodb_endpoint" {
  description = "Whether to create DynamoDB gateway endpoint"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
