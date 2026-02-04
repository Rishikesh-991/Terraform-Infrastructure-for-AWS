variable "environment" { type = string }
variable "create" { type = bool default = false }
variable "cluster_name" { type = string default = "eks-${var.environment}" }
variable "vpc_id" { type = string default = "" }
variable "subnet_ids" { type = list(string) default = [] }
variable "tags" { type = map(string) default = {} }
