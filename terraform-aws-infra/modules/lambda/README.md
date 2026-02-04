# Lambda Module

**Purpose:** Creates AWS Lambda functions with proper IAM roles, VPC integration, environment variables, and monitoring.

## What It Creates

- **Lambda Function:** With specified runtime (Python, Node.js, Go, etc.)
- **Execution Role:** IAM role with permissions for logs, VPC, X-Ray
- **Security Group Integration:** For VPC-attached functions
- **CloudWatch Logs:** For function output and debugging
- **Environment Variables:** For configuration injection
- **Aliases:** For versioning and traffic shifting
- **CloudWatch Alarms:** For monitoring errors and duration

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable Lambda creation |
| `function_name` | string | - | Lambda function name |
| `runtime` | string | `python3.11` | Runtime (python3.11, nodejs18.x, go1.x, etc.) |
| `handler` | string | - | Handler (path/to/handler.function) |
| `filename` | string | - | Path to ZIP file or S3 key |
| `s3_bucket` | string | - | S3 bucket containing function code |
| `s3_key` | string | - | S3 key for function code |
| `role_arn` | string | - | IAM role ARN for execution |
| `timeout` | number | `30` | Timeout in seconds |
| `memory_size` | number | `128` | Memory in MB (128-10240) |
| `environment_variables` | map(string) | `{}` | Environment variables |
| `vpc_config` | object | `{}` | VPC configuration (subnet_ids, security_group_ids) |
| `reserved_concurrent_executions` | number | `-1` | Concurrency limit (-1 = unlimited) |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `function_arn` | Lambda function ARN |
| `function_name` | Lambda function name |
| `function_version` | Latest function version |
| `execution_role_arn` | IAM execution role ARN |
| `cloudwatch_log_group_name` | CloudWatch Logs group name |

## Usage Example

```hcl
# Create Lambda function from S3
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-code"
  output_path = "${path.module}/lambda-code.zip"
}

module "lambda" {
  source = "../../modules/lambda"

  create          = true
  function_name   = "my-app-processor"
  runtime         = "python3.11"
  handler         = "index.handler"
  filename        = data.archive_file.lambda_zip.output_path
  timeout         = 60
  memory_size     = 512

  environment_variables = {
    ENV        = "prod"
    DB_ENDPOINT = module.databases.db_instance_endpoint
    TABLE_NAME  = aws_dynamodb_table.events.name
  }

  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.security_groups.app_sg_id]
  }

  tags = {
    Environment = "prod"
  }
}

# Invoke from API Gateway, SNS, SQS, etc.
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
```

## Best Practices

✅ **Environment Variables:** Use for configuration, not hardcoded values  
✅ **Concurrency Control:** Set reserved concurrency to prevent runaway costs  
✅ **Memory Allocation:** Higher memory = faster CPU (test for cost-performance)  
✅ **VPC Access:** Only when needed (adds cold-start time)  
✅ **Dead-Letter Queue:** Capture failed invocations  

## Phase

**Phase 3** — Serverless
