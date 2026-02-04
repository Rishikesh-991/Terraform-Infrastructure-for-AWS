variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "table_name" { type = string default = "" }
variable "hash_key" { type = string default = "id" }
variable "attributes" { type = list(any) default = [{ name = "id", type = "S" }] }
variable "tags" { type = map(string) default = {} }
