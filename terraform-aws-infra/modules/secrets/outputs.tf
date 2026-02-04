output "secrets_ids" { value = keys(aws_secretsmanager_secret.secrets) }
output "ssm_parameter_names" { value = keys(aws_ssm_parameter.params) }
