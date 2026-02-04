variable "environment" {
  description = "Environment name (dev/stage/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, stage, or prod"
  }
}

variable "create_cross_env_role" {
  description = "Create cross-environment CI/CD role"
  type        = bool
  default     = true
}

variable "create_cross_account_role" {
  description = "Create cross-account access role"
  type        = bool
  default     = false
}

variable "trusted_account_id" {
  description = "AWS account ID trusted for cross-account access"
  type        = string
  default     = ""
  validation {
    condition     = var.trusted_account_id == "" || can(regex("^\\d{12}$", var.trusted_account_id))
    error_message = "Trusted account ID must be a 12-digit number or empty"
  }
}

variable "external_id" {
  description = "External ID for cross-account assume role"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
