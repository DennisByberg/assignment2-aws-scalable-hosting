import json
import boto3
import os


def lambda_handler(event, context):
    try:
        # Initialize DynamoDB
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table(os.environ.get("DYNAMODB_TABLE"))

        # Get all greetings
        response = table.scan()

        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps(response["Items"]),
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)}),
        }
