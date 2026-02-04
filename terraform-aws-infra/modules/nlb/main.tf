resource "aws_lb" "nlb" {
  count = var.create ? 1 : 0
  name = "nlb-${var.environment}"
  internal = false
  load_balancer_type = "network"
  subnets = var.subnet_ids
  tags = var.tags
}
