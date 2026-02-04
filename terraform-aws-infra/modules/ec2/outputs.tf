output "launch_template_id" { value = try(aws_launch_template.default[0].id, null) }
