variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "engine" { type = string default = "aurora-postgresql" }
variable "instance_class" { type = string default = "db.r5.large" }
variable "subnet_group_name" { type = string default = "" }
variable "vpc_security_group_ids" { type = list(string) default = [] }
variable "tags" { type = map(string) default = {} }
