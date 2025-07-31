variable "lambda_function" { type = string }
variable "user_pool_arn" { type = string }
variable "environment" { type = string }

variable "aws_region" {
  description = "The AWS region for REST API endpoint construction"
  type        = string
}
variable "lambda_function_name" {
  type = string
}
