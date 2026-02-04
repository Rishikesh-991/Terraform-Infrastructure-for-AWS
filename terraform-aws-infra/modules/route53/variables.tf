variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "zone_name" { type = string default = "" }
variable "tags" { type = map(string) default = {} }
