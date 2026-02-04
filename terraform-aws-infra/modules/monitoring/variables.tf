variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "log_group_name" { type = string default = "app-logs-${var.environment}" }
variable "dashboards" { type = map(string) default = {} }
variable "alarms" { type = list(any) default = [] }
variable "tags" { type = map(string) default = {} }
