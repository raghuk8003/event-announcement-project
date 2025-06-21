resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic" {
  name       = "lambda-basic-policy"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_s3_access" {
  name       = "lambda-s3-access"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Custom IAM Policy: Allow Lambda to publish to SNS
resource "aws_iam_policy" "lambda_sns_publish" {
  name        = "LambdaSNSPublish"
  description = "Allow Lambda to publish and subscribe to SNS"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sns:Publish",
          "sns:Subscribe"
        ],
        Resource = aws_sns_topic.event_topic.arn
      }
    ]
  })
}


resource "aws_iam_policy_attachment" "lambda_sns_publish_attach" {
  name       = "lambda-sns-publish"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = aws_iam_policy.lambda_sns_publish.arn
}

# Zip the Lambda source code
data "archive_file" "subscription_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/subscription_lambda.py"
  output_path = "${path.module}/lambdas/subscription_lambda.zip"
}

data "archive_file" "event_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/event_registration_lambda.py"
  output_path = "${path.module}/lambdas/event_registration_lambda.zip"
}

# Lambda Function: Subscription
resource "aws_lambda_function" "subscription_lambda" {
  function_name    = "SubscriptionLambda"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "python3.10"
  handler          = "subscription_lambda.lambda_handler"
  filename         = data.archive_file.subscription_lambda_zip.output_path
  source_code_hash = data.archive_file.subscription_lambda_zip.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.event_topic.arn
    }
  }
}

# Lambda Function: Event Registration
resource "aws_lambda_function" "event_lambda" {
  function_name    = "EventRegistrationLambda"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "python3.10"
  handler          = "event_registration_lambda.lambda_handler"
  filename         = data.archive_file.event_lambda_zip.output_path
  source_code_hash = data.archive_file.event_lambda_zip.output_base64sha256

  # 👇 pass the topic ARN so the code can read os.environ["SNS_TOPIC_ARN"]
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.event_topic.arn
    }
  }
}

