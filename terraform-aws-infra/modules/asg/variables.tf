variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "launch_template_id" { type = string default = "" }
variable "min_size" { type = number default = 1 }
variable "max_size" { type = number default = 2 }
variable "subnet_ids" { type = list(string) default = [] }
variable "tags" { type = map(string) default = {} }
