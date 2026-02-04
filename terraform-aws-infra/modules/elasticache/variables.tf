variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "node_type" { type = string default = "cache.t3.micro" }
variable "num_cache_nodes" { type = number default = 1 }
variable "subnet_group_name" { type = string default = "" }
variable "security_group_ids" { type = list(string) default = [] }
variable "tags" { type = map(string) default = {} }
