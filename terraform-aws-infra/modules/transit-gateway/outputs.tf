output "transit_gateway_id" { value = try(aws_ec2_transit_gateway.this[0].id, "") }
