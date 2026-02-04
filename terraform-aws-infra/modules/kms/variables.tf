variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "description" { type = string default = "KMS key for ${var.environment}" }
variable "tags" { type = map(string) default = {} }
