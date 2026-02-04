resource "aws_ssm_document" "docs" {
  for_each = var.create ? var.documents : {}
  name = each.key
  document_type = lookup(each.value, "type", "Command")
  content = jsonencode(lookup(each.value, "content", {}))
}
