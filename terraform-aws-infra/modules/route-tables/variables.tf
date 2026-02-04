variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "internet_gateway_id" { type = string }
variable "nat_gateway_ids" { type = list(string) }
variable "create_public_route_table" { type = bool, default = true }
variable "tags" { type = map(string), default = {} }
