output "lambda_function_name" {
  value = module.lambda.lambda_function_name
}

output "lambda_function_arn" {
  value = module.lambda.lambda_function_arn
}

output "api_gateway_invoke_url" {
  value = module.api_gateway.api_invoke_url
}

output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "sns_topic_arn" {
  value = module.monitoring.sns_topic_arn
}
