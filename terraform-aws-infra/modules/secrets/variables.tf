variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "secrets" { type = map(any) default = {} }
variable "ssm_parameters" { type = map(any) default = {} }
variable "tags" { type = map(string) default = {} }
