variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "pipeline_name" { type = string default = "infra-pipeline-${var.environment}" }
variable "tags" { type = map(string) default = {} }
