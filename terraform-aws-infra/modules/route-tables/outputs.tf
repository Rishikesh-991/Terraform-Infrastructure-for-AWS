output "public_route_table_id" { value = try(aws_route_table.public[0].id, null) }
output "private_route_table_ids" { value = aws_route_table.private[*].id }
