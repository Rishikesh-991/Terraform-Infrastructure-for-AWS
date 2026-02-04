resource "aws_lambda_function" "func" {
  count = var.create ? 1 : 0
  function_name = var.function_name != "" ? var.function_name : "lambda-${var.environment}"
  handler = var.handler
  runtime = var.runtime
  s3_bucket = var.s3_bucket
  s3_key = var.s3_key
  publish = true
  tags = var.tags
}
