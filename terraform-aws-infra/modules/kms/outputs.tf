output "kms_key_id" { value = try(aws_kms_key.this[0].id, "") }
output "kms_key_arn" { value = try(aws_kms_key.this[0].arn, "") }
