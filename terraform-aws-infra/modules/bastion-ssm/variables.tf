variable "environment" { type = string }
variable "create_bastion" { type = bool default = false }
variable "ami_id" { type = string default = "ami-REPLACE_ME" }
variable "instance_type" { type = string default = "t3.micro" }
variable "key_name" { type = string default = "" }
variable "subnet_id" { type = string default = "" }
variable "vpc_id" { type = string default = "" }
variable "management_cidrs" { type = list(string) default = ["0.0.0.0/0"] }
variable "tags" { type = map(string) default = {} }
