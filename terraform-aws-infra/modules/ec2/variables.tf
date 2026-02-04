variable "environment" { type = string }
variable "create_instance" { type = bool, default = false }
variable "ami_id" { type = string, default = "ami-0c94855ba95c71c99" }
variable "instance_type" { type = string, default = "t3.micro" }
variable "instance_profile_name" { type = string, default = "" }
variable "security_group_ids" { type = list(string), default = [] }
variable "associate_public_ip" { type = bool, default = false }
variable "tags" { type = map(string), default = {} }
