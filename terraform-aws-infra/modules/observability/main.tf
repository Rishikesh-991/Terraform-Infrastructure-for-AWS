resource "aws_cloudwatch_log_group" "observability" {
  count = var.create ? 1 : 0
  name  = var.log_group_name
  retention_in_days = var.log_retention_days
  tags = var.tags
}

resource "aws_cloudwatch_dashboard" "dash" {
  count = var.create && length(keys(var.dashboard_definitions)) > 0 ? length(var.dashboard_definitions) : 0
  for_each = var.create ? var.dashboard_definitions : {}
  dashboard_name = each.key
  dashboard_body = each.value
}
