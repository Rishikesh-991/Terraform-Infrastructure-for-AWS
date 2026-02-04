# Monitoring / Logging (CloudWatch)
resource "aws_cloudwatch_log_group" "central" {
  count = var.create ? 1 : 0
  name = var.log_group_name
  retention_in_days = 30
  tags = var.tags
}

resource "aws_cloudwatch_dashboard" "basic" {
  count = var.create && length(values(var.dashboards)) > 0 ? 1 : 0
  dashboard_name = "dashboard-${var.environment}"
  dashboard_body = jsonencode({ widgets = [] })
}

resource "aws_cloudwatch_metric_alarm" "from_list" {
  count = var.create ? length(var.alarms) : 0
  alarm_name = "alarm-${var.environment}-${count.index}"
  comparison_operator = lookup(var.alarms[count.index], "comparison_operator", "GreaterThanThreshold")
  evaluation_periods  = lookup(var.alarms[count.index], "evaluation_periods", 1)
  metric_name = lookup(var.alarms[count.index], "metric_name", "CPUUtilization")
  namespace = lookup(var.alarms[count.index], "namespace", "AWS/EC2")
  threshold = lookup(var.alarms[count.index], "threshold", 80)
}
