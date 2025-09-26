import json
import boto3
from boto3.dynamodb.conditions import Key
import os
from datetime import datetime, timezone
import uuid


def lambda_handler(event, context):
    print(f"Received event: {json.dumps(event)}")

    # Handle CORS preflight
    if event.get("httpMethod") == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type",
            },
            "body": "",
        }

    try:
        # Parse request body
        body = json.loads(event.get("body", "{}"))
        print(f"Parsed body: {json.dumps(body)}")

        # Check if body is empty or null
        if not body:
            return {
                "statusCode": 400,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type",
                },
                "body": json.dumps({"error": "Request body is empty"}),
            }

        # Validate required fields
        name = body.get("name", "").strip()
        email = body.get("email", "").strip()
        message = body.get("message", "").strip()

        if not name or not email or not message:
            return {
                "statusCode": 400,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type",
                },
                "body": json.dumps(
                    {
                        "error": "Missing required fields: name, email, message",
                        "received": {"name": name, "email": email, "message": message},
                    }
                ),
            }

        # Initialize DynamoDB resource
        dynamodb = boto3.resource("dynamodb")  # type: ignore
        table_name = os.environ.get("CONTACTS_TABLE_NAME")

        if not table_name:
            print("CONTACTS_TABLE_NAME environment variable not set")
            return {
                "statusCode": 500,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type",
                },
                "body": json.dumps({"error": "Server configuration error"}),
            }

        table = dynamodb.Table(table_name)  # type: ignore

        # Create contact item
        contact_item = {
            "id": str(uuid.uuid4()),
            "name": name,
            "email": email,
            "message": message,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

        print(f"Saving contact item: {json.dumps(contact_item)}")

        # Save to DynamoDB
        table.put_item(Item=contact_item)

        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": "Contact saved successfully"}),
        }

    except Exception as e:
        print(f"Error processing contact info: {str(e)}")
        import traceback

        print(f"Traceback: {traceback.format_exc()}")

        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)}),
        }
