resource "aws_lambda_function" "main" {
  function_name    = var.function_name
  handler          = var.handler
  runtime          = var.runtime
  filename         = var.lambda_package_path
  source_code_hash = filebase64sha256(var.lambda_package_path)
  role             = var.iam_role_arn
  memory_size      = 128
  timeout          = 60

  environment {
    variables = {
      S3_BUCKET      = var.s3_bucket
      DYNAMODB_TABLE = var.dynamodb_table
      ENVIRONMENT    = var.environment
    }
  }
}

output "lambda_function_name" { value = aws_lambda_function.main.function_name }
output "lambda_function_arn"  { value = aws_lambda_function.main.arn }
