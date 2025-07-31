resource "aws_cloudwatch_metric_alarm" "high_alerts" {
  alarm_name          = "HighPriorityAlertsAlarm-${var.environment}"
  metric_name         = "HighPriorityAlerts"
  namespace           = "Custom"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 3
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_sns_topic" "alerts" {
  name = var.sns_topic_name
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "LambdaErrorsAlarm-${var.environment}"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    FunctionName = var.lambda_function_name
  }
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
