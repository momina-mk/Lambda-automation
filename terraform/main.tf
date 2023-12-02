 provider "aws" {
  region = "us-east-1" 
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_lambda_function" "myfunction" {
  function_name = "myfunction"
  handler      = "index.handler"
  runtime      = "nodejs18.x"
  filename     = filebase64("${path.module}./index.zip")

  source_code_hash = filebase64sha256("${path.module}./index.zip")

  role = aws_iam_role.lambda_exec.arn
}



