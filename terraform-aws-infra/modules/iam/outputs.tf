output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2_instance.name
}

output "ec2_instance_profile_arn" {
  description = "EC2 instance profile ARN"
  value       = aws_iam_instance_profile.ec2_instance.arn
}

output "ec2_instance_role_arn" {
  description = "EC2 instance role ARN"
  value       = aws_iam_role.ec2_instance.arn
}

output "application_role_arn" {
  description = "Application role ARN (ECS/EKS)"
  value       = aws_iam_role.application.arn
}

output "application_role_name" {
  description = "Application role name"
  value       = aws_iam_role.application.name
}

output "lambda_execution_role_arn" {
  description = "Lambda execution role ARN"
  value       = aws_iam_role.lambda_execution.arn
}

output "lambda_execution_role_name" {
  description = "Lambda execution role name"
  value       = aws_iam_role.lambda_execution.name
}

output "rds_monitoring_role_arn" {
  description = "RDS monitoring role ARN"
  value       = aws_iam_role.rds_monitoring.arn
}

output "cross_env_role_arn" {
  description = "Cross-environment CI/CD role ARN"
  value       = try(aws_iam_role.cross_env[0].arn, null)
}

output "cross_account_role_arn" {
  description = "Cross-account access role ARN"
  value       = try(aws_iam_role.cross_account[0].arn, null)
}

output "iam_roles_summary" {
  description = "Summary of all created IAM roles"
  value = {
    ec2_instance_profile = aws_iam_instance_profile.ec2_instance.name
    ec2_instance_role    = aws_iam_role.ec2_instance.name
    application_role     = aws_iam_role.application.name
    lambda_role          = aws_iam_role.lambda_execution.name
    rds_monitoring_role  = aws_iam_role.rds_monitoring.name
    cross_env_role       = try(aws_iam_role.cross_env[0].name, "Not created")
    cross_account_role   = try(aws_iam_role.cross_account[0].name, "Not created")
  }
}
