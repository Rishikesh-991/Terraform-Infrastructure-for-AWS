# EC2 module - optional launch template using IAM instance profile
resource "aws_launch_template" "default" {
  count = var.create_instance ? 1 : 0

  name_prefix   = "${var.environment}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    security_groups = var.security_group_ids
    associate_public_ip_address = var.associate_public_ip
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, { Name = "${var.environment}-instance" })
  }
}

output "launch_template_id" {
  value = try(aws_launch_template.default[0].id, null)
}
