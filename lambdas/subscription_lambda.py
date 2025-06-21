import json
import boto3
import os

sns_client = boto3.client("sns")

def lambda_handler(event, context):
    body = json.loads(event["body"])
    email = body.get("email")

    if not email:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Email is required"})
        }

    topic_arn = os.environ["SNS_TOPIC_ARN"]

    # Subscribe the email to the SNS topic
    response = sns_client.subscribe(
        TopicArn=topic_arn,
        Protocol="email",
        Endpoint=email,
        ReturnSubscriptionArn=True
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": f"Subscription request sent to {email}"})
    }
