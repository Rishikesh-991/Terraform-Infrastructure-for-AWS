resource "aws_dynamodb_table" "this" {
  count = var.create ? 1 : 0
  name = var.table_name != "" ? var.table_name : "dynamo-${var.environment}"
  hash_key = var.hash_key
  attribute = var.attributes
  billing_mode = "PAY_PER_REQUEST"
  tags = var.tags
}
