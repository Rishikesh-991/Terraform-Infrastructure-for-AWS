variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "subnet_ids" { type = list(string) default = [] }
variable "tags" { type = map(string) default = {} }
