# Route Tables module - creates public/private route tables and associations
# Note: VPC module already creates route tables; this module is reusable for refined routing

resource "aws_route_table" "public" {
  count  = var.create_public_route_table ? 1 : 0
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = merge(var.tags, { Name = "${var.environment}-public-rt" })
}

resource "aws_route_table_association" "public_assoc" {
  count          = var.create_public_route_table ? length(var.public_subnet_ids) : 0
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_ids)
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_ids[count.index % length(var.nat_gateway_ids)]
  }

  tags = merge(var.tags, { Name = "${var.environment}-private-rt-${count.index + 1}" })
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private[count.index].id
}
