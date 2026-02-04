output "log_group_name" { value = try(aws_cloudwatch_log_group.observability[0].name, "") }
output "dashboards" { value = try([for d in aws_cloudwatch_dashboard.dash : d.dashboard_name], []) }
