import json
import boto3
import os


def lambda_handler(event, context):
    try:
        # Initialize SES client
        ses = boto3.client("ses")
        from_email = os.environ.get("FROM_EMAIL")
        to_email = os.environ.get("TO_EMAIL")

        # Process DynamoDB stream records
        for record in event["Records"]:
            if record["eventName"] == "INSERT":
                # Extract contact information from DynamoDB stream
                item = record["dynamodb"]["NewImage"]
                name = item["name"]["S"]
                email = item["email"]["S"]
                message = item["message"]["S"]

                # Send email notification
                ses.send_email(
                    Source=from_email,
                    Destination={"ToAddresses": [to_email]},
                    Message={
                        "Subject": {"Data": f"Contact from {name}"},
                        "Body": {
                            "Text": {
                                "Data": f"Name: {name}\nEmail: {email}\nMessage: {message}"
                            }
                        },
                    },
                )

        return {"statusCode": 200}

    except Exception as e:
        return {"statusCode": 500, "body": json.dumps(str(e))}
