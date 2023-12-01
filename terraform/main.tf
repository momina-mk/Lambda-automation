provider "aws" {
  region = "us-east-1" 
}

resource "aws_lambda_function" "myfunction" {
  function_name = "myfunction"
  handler      = "index.handler"
  runtime      = "nodejs18.x"
  filename     = "code.zip"

  source_code_hash = filebase64sha256("code.zip")

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.lambda_topic.arn
      API_URL       = aws_api_gateway_deployment.my_lambda_gateway_deployment.url
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com",
      },
    }],
  })
}

resource "aws_sns_topic" "lambda_topic" {
  name = "LambdaNotificationTopic"
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.lambda_topic.arn
  protocol  = "email"
  endpoint  = "mominamalik985@gmail.com"  
}

resource "aws_api_gateway_rest_api" "my_lambda_api" {
  name        = "MyAPI"
  description = "API for my Lambda function"
}

resource "aws_api_gateway_resource" "my_lambda_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_lambda_api.id
  parent_id   = aws_api_gateway_rest_api.my_lambda_api.root_resource_id
  path_part   = "my-function"
}

resource "aws_api_gateway_method" "my_lambda_api_gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_lambda_api.id
  resource_id   = aws_api_gateway_resource.my_lambda_gateway_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "my_lambda_api_gateway_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_lambda_api.id
  resource_id             = aws_api_gateway_resource.my_lambda_gateway_resource.id
  http_method             = aws_api_gateway_method.my_lambda_api_gateway_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.myfunction.invoke_arn
}

resource "aws_api_gateway_deployment" "my_lambda_gateway_deployment" {
  depends_on = [aws_api_gateway_integration.my_lambda_api_gateway_integration]

  rest_api_id = aws_api_gateway_rest_api.my_lambda_api.id
  stage_name  = "prod"
}

