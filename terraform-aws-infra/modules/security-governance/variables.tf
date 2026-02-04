variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "enable_guardduty" { type = bool default = true }
variable "enable_security_hub" { type = bool default = true }
variable "enable_config" { type = bool default = true }
variable "tags" { type = map(string) default = {} }
