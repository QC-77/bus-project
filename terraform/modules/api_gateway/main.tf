resource "aws_api_gateway_rest_api" "api" {
  name        = "nyc-data-api-${var.environment}"
  description = "NYC Data API Entry"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "bus"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_function}/invocations"
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name =  var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/POST/bus"
}

resource "aws_api_gateway_authorizer" "cognito" {
  name                    = "cognito"
  rest_api_id             = aws_api_gateway_rest_api.api.id
  authorizer_result_ttl_in_seconds = 300
  identity_source         = "method.request.header.Authorization"
  type                    = "COGNITO_USER_POOLS"
  provider_arns           = [var.user_pool_arn]
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on   = [aws_api_gateway_integration.lambda]
  rest_api_id  = aws_api_gateway_rest_api.api.id
  
}

resource "aws_api_gateway_stage" "apistage" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.api.id  
  deployment_id = aws_api_gateway_deployment.deployment.id
}

output "api_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.apistage.stage_name}/bus"
}

