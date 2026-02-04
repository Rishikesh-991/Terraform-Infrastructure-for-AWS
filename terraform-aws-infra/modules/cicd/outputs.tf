output "cicd_role_name" { value = try(aws_iam_role.cicd_role[0].name, "") }
