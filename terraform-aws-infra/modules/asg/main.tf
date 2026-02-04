resource "aws_autoscaling_group" "asg" {
  count = var.create ? 1 : 0
  name = "asg-${var.environment}"
  max_size = var.max_size
  min_size = var.min_size
  vpc_zone_identifier = var.subnet_ids
  launch_template { id = var.launch_template_id }
  tags = [{ key = "Name", value = "asg-${var.environment}", propagate_at_launch = true }]
}
