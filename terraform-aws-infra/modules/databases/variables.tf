variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "engine" { type = string default = "postgres" }
variable "instance_class" { type = string default = "db.t3.medium" }
variable "allocated_storage" { type = number default = 20 }
variable "multi_az" { type = bool default = false }
variable "subnet_group_name" { type = string default = "" }
variable "vpc_security_group_ids" { type = list(string) default = [] }
variable "tags" { type = map(string) default = {} }
