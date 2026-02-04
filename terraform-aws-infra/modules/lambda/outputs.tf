output "lambda_arn" { value = try(aws_lambda_function.func[0].arn, "") }
