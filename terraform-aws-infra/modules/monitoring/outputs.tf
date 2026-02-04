output "log_group_name" { value = aws_cloudwatch_log_group.central[0].name }
output "dashboard_name" { value = try(aws_cloudwatch_dashboard.basic[0].dashboard_name, "") }
