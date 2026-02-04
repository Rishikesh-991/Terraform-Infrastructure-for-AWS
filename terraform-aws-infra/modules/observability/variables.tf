variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "log_group_name" { type = string default = "observability-${var.environment}" }
variable "dashboard_definitions" { type = map(string) default = {} }
variable "log_retention_days" { type = number default = 30 }
variable "tags" { type = map(string) default = {} }
