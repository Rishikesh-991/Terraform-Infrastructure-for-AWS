resource "aws_route53_zone" "zone" {
  count = var.create ? 1 : 0
  name = var.zone_name
  tags = var.tags
}
