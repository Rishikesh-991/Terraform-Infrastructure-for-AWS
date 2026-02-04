resource "aws_kms_key" "this" {
  count = var.create ? 1 : 0
  description = var.description
  deletion_window_in_days = 30
  tags = var.tags
}

resource "aws_kms_alias" "alias" {
  count = var.create ? 1 : 0
  name = "alias/${var.environment}-key"
  target_key_id = aws_kms_key.this[0].key_id
}
