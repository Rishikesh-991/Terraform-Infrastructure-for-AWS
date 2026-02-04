# Secrets Manager and SSM Parameter Store
resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.create ? var.secrets : {}
  name = "${each.key}-${var.environment}"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "secrets_version" {
  for_each = var.create ? var.secrets : {}
  secret_id = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = jsonencode(each.value)
}

resource "aws_ssm_parameter" "params" {
  for_each = var.create ? var.ssm_parameters : {}
  name  = "/${var.environment}/${each.key}"
  type  = lookup(each.value, "type", "String")
  value = lookup(each.value, "value", "")
  tags  = var.tags
}
