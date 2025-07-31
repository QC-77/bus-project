resource "aws_cognito_user_pool" "user_pool" {
  name = "busdata-user-pool-${var.environment}"
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "busdata-client-${var.environment}"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  generate_secret     = false
}
output "user_pool_id"  { value = aws_cognito_user_pool.user_pool.id }
output "user_pool_arn" { value = aws_cognito_user_pool.user_pool.arn }
