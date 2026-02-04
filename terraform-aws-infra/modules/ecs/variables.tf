variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "cluster_name" { type = string default = "ecs-${var.environment}" }
variable "tags" { type = map(string) default = {} }
