resource "aws_budgets_budget" "this" {
  for_each = var.create ? var.budgets : {}
  name = each.key
  budget_type = lookup(each.value, "budget_type", "COST")
  limit_amount = tostring(lookup(each.value, "limit", 100))
  limit_unit = "USD"
  time_unit = lookup(each.value, "time_unit", "MONTHLY")
}
