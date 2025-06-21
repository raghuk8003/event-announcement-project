import json
import boto3
import os

sns = boto3.client('sns')
topic_arn = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    body = json.loads(event['body'])  # Parse JSON string to dict
    name = body['name']
    email = body['email']

    message = f"New event registration:\nName: {name}\nEmail: {email}"

    response = sns.publish(
        TopicArn=topic_arn,
        Message=message,
        Subject='New Event Registration'
    )

    return {
        'statusCode': 200,
        'body': json.dumps({'message': f'Event registered for {name}'})
    }
