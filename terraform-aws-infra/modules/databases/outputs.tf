output "rds_endpoint" { value = try(aws_db_instance.this[0].address, "") }
output "rds_id" { value = try(aws_db_instance.this[0].id, "") }
