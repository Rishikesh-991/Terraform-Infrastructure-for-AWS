output "asg_id" { value = try(aws_autoscaling_group.asg[0].id, "") }
