variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "budgets" { type = map(any) default = {} }
variable "tags" { type = map(string) default = {} }
