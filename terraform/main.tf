provider "aws" {
  region = "us-east-1"
}
data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/nodejs/*"
  output_path = "${path.module}/index.zip"
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
  runtime      = "nodejs14.x"
  filename     = data.archive_file.zip_the_python_code.output_path

  role = aws_iam_role.lambda_exec.arn
}


