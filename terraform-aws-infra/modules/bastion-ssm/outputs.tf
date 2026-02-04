output "launch_template_id" { value = try(aws_launch_template.bastion_lt[0].id, "") }
output "instance_profile_name" { value = try(aws_iam_instance_profile.bastion_profile[0].name, "") }
