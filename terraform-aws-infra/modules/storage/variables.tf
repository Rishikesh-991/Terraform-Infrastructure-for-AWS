variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "bucket_name" { type = string default = "" }
variable "enable_cloudfront" { type = bool default = false }
variable "tags" { type = map(string) default = {} }
