import os
import json
import boto3
import logging
import re

# === SETUP AND CLIENTS ===

# Set up a logger for CloudWatch structured JSON logs
logger = logging.getLogger()
logger.setLevel(logging.INFO)  # Ensures all INFO+ messages go to CloudWatch

# Initialize AWS SDK clients for S3 (raw payloads), DynamoDB (enriched
# data), and CloudWatch (metrics)
s3 = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")
cloudwatch = boto3.client("cloudwatch")

# Read resource names from Lambda environment variables (set by Terraform)
S3_BUCKET = os.environ.get("S3_BUCKET")
DYNAMODB_TABLE = os.environ.get("DYNAMODB_TABLE")

# List of fields that must be present in the incoming event (for reliable
# data processing)
REQUIRED_FIELDS = ["Busbreakdown_ID", "Route_Number", "Reason"]

# === ALERT PRIORITY MAPPING ===
# Business logic: Map Reason to alert_priority (used for downstream
# alerting and metric emission)
PRIORITY_MAP = {
    "Mechanical Problem": "high",
    "Flat Tire": "high",
    "Won't Start": "high",
    "Accident": "high",
    "Heavy Traffic": "medium",
    "Weather Conditions": "medium",
    "Delayed by School": "low",
    "Other": "low",
    "Problem Run": "low",
}


# === UTILITY: Parse time delay field into integer minutes ===
def parse_delay(delay_str):
    """
    Converts the `How_Long_Delayed` field (e.g. '25-35 Mins', '1 Hour')
    into an average integer number of minutes (for analytics).
    Handles single values, ranges, and 'Hour' formats.
    """
    if delay_str is None:
        return None
    mins = re.findall(r"\d+", delay_str)
    # Handle '1 Hour', '2 hour(s)' etc.
    if "hour" in delay_str.lower():
        return int(mins[0]) * 60 if mins else None
    # Handle ranges like '25-35 Mins'
    if "-" in delay_str and len(mins) == 2:
        return int((int(mins[0]) + int(mins[1])) / 2)
    # Handle plain minutes like '30 Min'
    return int(mins[0]) if mins else None


# === MAIN HANDLER ===
def lambda_handler(event, context):
    """
    Main entry point for all event processing.
    - Validates payload schema.
    - Enriches the event (alert_priority, average_delay_minutes).
    - Writes raw data to S3, enriched data to DynamoDB.
    - Structured CloudWatch log with event keys for easy search/troubleshooting.
    - Emits custom CloudWatch metric if alert priority is HIGH (for alarm/SNS).
    """
    # If event is from API Gateway, extract the JSON body
    body = event
    if "body" in event:
        try:
            body = json.loads(event["body"])
        except Exception as e:
            print(e)
            # Return API error promptly if request body is malformatted
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Malformed JSON body."}),
            }

    # Validate required fields are present
    missing = [f for f in REQUIRED_FIELDS if f not in body]
    if missing:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": f"Missing fields: {', '.join(missing)}"}),
        }

    # === ENRICHMENT ===
    # Add 'alert_priority' and 'average_delay_minutes' fields
    reason = body["Reason"]
    body["alert_priority"] = PRIORITY_MAP.get(
        reason, "low"
    )  # Default 'low' if not matched
    body["average_delay_minutes"] = parse_delay(body.get("How_Long_Delayed"))

    # === OBSERVABILITY: Structured Logging ===
    # Create a log entry keyed by Busbreakdown_ID and Route_Number for fast
    # trace/search
    log_data = {
        "Busbreakdown_ID": body.get("Busbreakdown_ID"),
        "Route_Number": body.get("Route_Number"),
        "event_status": "received",
    }
    logger.info(json.dumps(log_data))  # CloudWatch ingests as JSON

    # === STORE RAW EVENT IN S3 ===
    # All original events are stored as immutable .json for replay/audit
    s3.put_object(
        Bucket=S3_BUCKET,
        Key=f"raw/{body['Busbreakdown_ID']}-{body['Route_Number']}.json",
        Body=json.dumps(body),
    )

    # === STORE ENRICHED EVENT IN DYNAMODB ===
    # Optimized for queries by Route_Number and Occurred_On as per project spec
    table = dynamodb.Table(DYNAMODB_TABLE)
    table.put_item(Item=body)

    # === MONITORING: Custom Metric for AlertingTrigger ===
    # If event is "high" alert_priority, emit CloudWatch metric for alarms/SNS
    if body["alert_priority"] == "high":
        cloudwatch.put_metric_data(
            Namespace="Custom",
            MetricData=[
                {"MetricName": "HighPriorityAlerts", "Value": 1, "Unit": "Count"}
            ],
        )
    # Return HTTP success for API Gateway
    return {"statusCode": 200, "body": json.dumps({"status": "success"})}
