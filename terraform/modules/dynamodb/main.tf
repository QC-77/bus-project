resource "aws_dynamodb_table" "main" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Route_Number"
  range_key      = "Occurred_On"

  attribute {
    name = "Route_Number"
    type = "S"
  }
  attribute {
    name = "Occurred_On"
    type = "S"
  }

  tags = {
    Environment = var.environment
  }
}

output "table_name" { value = aws_dynamodb_table.main.name }
output "table_arn"  { value = aws_dynamodb_table.main.arn }
