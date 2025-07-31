variable "aws_region" {
  description = "AWS region for deployment"
  type    = string
  default = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type    = string
  default = "dev"
}

variable "s3_bucket_name" {
  description = "S3 bucket for raw data"
  type = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table for enriched data"
  type = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type    = string
}

variable "lambda_handler" {
  description = "Lambda handler"
  type    = string
  default = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type    = string
  default = "python3.9"
}

variable "lambda_package_path" {
  description = "Zip path for Lambda code"
  type = string
}

variable "sns_topic_name" {
  description = "SNS Topic name for alerts"
  type    = string
  default = "high_priority_alerts"
}
