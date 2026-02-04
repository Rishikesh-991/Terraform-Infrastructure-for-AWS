resource "aws_ec2_transit_gateway" "this" {
  count = var.create ? 1 : 0
  description = var.description
  tags = var.tags
}

# VPC attachments will be created by consumers when enabling
resource "aws_ec2_transit_gateway_vpc_attachment" "attachment" {
  count = 0
  subnet_ids = []
  transit_gateway_id = aws_ec2_transit_gateway.this[0].id
  vpc_id = ""
}
