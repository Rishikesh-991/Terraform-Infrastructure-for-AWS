variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "management_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "alb_allowed_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "tags" {
  type    = map(string)
  default = {}
}
