resource "aws_lb" "alb" {
  count = var.create ? 1 : 0
  name = "alb-${var.environment}"
  internal = false
  load_balancer_type = "application"
  subnets = var.subnet_ids
  security_groups = var.security_group_ids
  tags = var.tags
}
