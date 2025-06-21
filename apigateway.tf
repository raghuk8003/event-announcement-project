# Create REST API
resource "aws_api_gateway_rest_api" "event_api" {
  name        = "event-api"
  description = "API Gateway for event registration and subscription"
}

# /new-events resource
resource "aws_api_gateway_resource" "new_events" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  parent_id   = aws_api_gateway_rest_api.event_api.root_resource_id
  path_part   = "new-events"
}

# POST /new-events method
resource "aws_api_gateway_method" "post_events" {
  rest_api_id   = aws_api_gateway_rest_api.event_api.id
  resource_id   = aws_api_gateway_resource.new_events.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration: POST /new-events -> Lambda
resource "aws_api_gateway_integration" "events_integration" {
  rest_api_id             = aws_api_gateway_rest_api.event_api.id
  resource_id             = aws_api_gateway_resource.new_events.id
  http_method             = aws_api_gateway_method.post_events.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.event_lambda.invoke_arn
}

# Lambda permission for /new-events
resource "aws_lambda_permission" "allow_apigw_events" {
  statement_id  = "AllowAPIGatewayInvokeEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.event_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.event_api.execution_arn}/*/*"
}

# OPTIONAL: /subscribers resource (if you have a second Lambda)
resource "aws_api_gateway_resource" "subscribers" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  parent_id   = aws_api_gateway_rest_api.event_api.root_resource_id
  path_part   = "subscribers"
}

resource "aws_api_gateway_method" "post_subscribers" {
  rest_api_id   = aws_api_gateway_rest_api.event_api.id
  resource_id   = aws_api_gateway_resource.subscribers.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "subscribers_integration" {
  rest_api_id             = aws_api_gateway_rest_api.event_api.id
  resource_id             = aws_api_gateway_resource.subscribers.id
  http_method             = aws_api_gateway_method.post_subscribers.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.subscription_lambda.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw_subscribers" {
  statement_id  = "AllowAPIGatewayInvokeSubscribers"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscription_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.event_api.execution_arn}/*/*"
}

# NEW: /subscribe resource for email to SNS
resource "aws_api_gateway_resource" "subscribe" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  parent_id   = aws_api_gateway_rest_api.event_api.root_resource_id
  path_part   = "subscribe"
}

resource "aws_api_gateway_method" "post_subscribe" {
  rest_api_id   = aws_api_gateway_rest_api.event_api.id
  resource_id   = aws_api_gateway_resource.subscribe.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "subscribe_integration" {
  rest_api_id             = aws_api_gateway_rest_api.event_api.id
  resource_id             = aws_api_gateway_resource.subscribe.id
  http_method             = aws_api_gateway_method.post_subscribe.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.subscription_lambda.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw_subscribe" {
  statement_id  = "AllowAPIGatewayInvokeSubscribe"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscription_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.event_api.execution_arn}/*/*"
}

# Deploy the API with all methods
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.events_integration,
    aws_api_gateway_integration.subscribers_integration,
    aws_api_gateway_integration.subscribe_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.event_api.id

# 👉 this forces a redeploy when any integration or method changes
  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_integration.events_integration.id,
      aws_api_gateway_integration.subscribers_integration.id,
      aws_api_gateway_integration.subscribe_integration.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway stage
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.event_api.id
  stage_name    = "prod"
}
