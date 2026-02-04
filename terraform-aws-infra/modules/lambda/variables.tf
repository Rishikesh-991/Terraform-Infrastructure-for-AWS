variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "function_name" { type = string default = "" }
variable "handler" { type = string default = "index.handler" }
variable "runtime" { type = string default = "python3.9" }
variable "s3_bucket" { type = string default = "" }
variable "s3_key" { type = string default = "" }
variable "tags" { type = map(string) default = {} }
