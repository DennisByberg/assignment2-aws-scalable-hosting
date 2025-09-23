# Data source for current AWS region
data "aws_region" "current" {}

# Create zip files for Lambda functions - updated paths
data "archive_file" "add_contact_info_zip" {
  type        = "zip"
  source_file = "${path.root}/../lambda/add_contact_info.py"
  output_path = "${path.root}/../build/add_contact_info.zip"
}

data "archive_file" "send_contact_email_zip" {
  type        = "zip"
  source_file = "${path.root}/../lambda/send_contact_email.py"
  output_path = "${path.root}/../build/send_contact_email.zip"
}

data "archive_file" "get_greetings_zip" {
  type        = "zip"
  source_file = "${path.root}/../lambda/get_greetings.py"
  output_path = "${path.root}/../build/get_greetings.zip"
}

# Lambda execution role for greetings function
resource "aws_iam_role" "lambda_greetings_role" {
  name = "${var.project_name}-${var.environment}-lambda-greetings-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda execution role for contact functions
resource "aws_iam_role" "lambda_contact_role" {
  name = "${var.project_name}-${var.environment}-lambda-contact-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Basic Lambda execution policy for greetings
resource "aws_iam_role_policy_attachment" "lambda_greetings_basic" {
  role       = aws_iam_role.lambda_greetings_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Basic Lambda execution policy for contact
resource "aws_iam_role_policy_attachment" "lambda_contact_basic" {
  role       = aws_iam_role.lambda_contact_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# DynamoDB policy for greetings function
resource "aws_iam_role_policy" "lambda_greetings_dynamodb" {
  name = "${var.project_name}-${var.environment}-lambda-greetings-dynamodb"
  role = aws_iam_role.lambda_greetings_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = var.greetings_table_arn
      }
    ]
  })
}

# DynamoDB policy for contact functions
resource "aws_iam_role_policy" "lambda_contact_dynamodb" {
  name = "${var.project_name}-${var.environment}-lambda-contact-dynamodb"
  role = aws_iam_role.lambda_contact_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        Resource = var.contacts_table_arn
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:ListStreams"
        ]
        Resource = var.contacts_table_stream_arn
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

# Get greetings Lambda function
resource "aws_lambda_function" "get_greetings" {
  filename         = data.archive_file.get_greetings_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-get-greetings"
  role             = aws_iam_role.lambda_greetings_role.arn
  handler          = "get_greetings.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.get_greetings_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = var.greetings_table_name
    }
  }
}

# Add contact info Lambda function
resource "aws_lambda_function" "add_contact_info" {
  filename         = data.archive_file.add_contact_info_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-add-contact-info"
  role             = aws_iam_role.lambda_contact_role.arn
  handler          = "add_contact_info.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.add_contact_info_zip.output_base64sha256

  environment {
    variables = {
      CONTACTS_TABLE_NAME = var.contacts_table_name
    }
  }
}

# Send contact email Lambda function
resource "aws_lambda_function" "send_contact_email" {
  filename         = data.archive_file.send_contact_email_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-send-contact-email"
  role             = aws_iam_role.lambda_contact_role.arn
  handler          = "send_contact_email.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.send_contact_email_zip.output_base64sha256

  environment {
    variables = {
      FROM_EMAIL = var.from_email
      TO_EMAIL   = var.to_email
    }
  }
}

# DynamoDB Stream trigger for send_contact_email
resource "aws_lambda_event_source_mapping" "contacts_stream" {
  event_source_arn  = var.contacts_table_stream_arn
  function_name     = aws_lambda_function.send_contact_email.arn
  starting_position = "LATEST"
}

# API Gateway for greetings
resource "aws_api_gateway_rest_api" "greetings_api" {
  name = "${var.project_name}-${var.environment}-greetings-api"
}

resource "aws_api_gateway_resource" "greetings_resource" {
  rest_api_id = aws_api_gateway_rest_api.greetings_api.id
  parent_id   = aws_api_gateway_rest_api.greetings_api.root_resource_id
  path_part   = "greetings"
}

resource "aws_api_gateway_method" "greetings_method" {
  rest_api_id   = aws_api_gateway_rest_api.greetings_api.id
  resource_id   = aws_api_gateway_resource.greetings_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "greetings_integration" {
  rest_api_id = aws_api_gateway_rest_api.greetings_api.id
  resource_id = aws_api_gateway_resource.greetings_resource.id
  http_method = aws_api_gateway_method.greetings_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_greetings.invoke_arn
}

resource "aws_lambda_permission" "allow_greetings_api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_greetings.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.greetings_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "greetings_deployment" {
  depends_on = [aws_api_gateway_integration.greetings_integration]

  rest_api_id = aws_api_gateway_rest_api.greetings_api.id
}

# API Gateway stage for greetings
resource "aws_api_gateway_stage" "greetings_stage" {
  deployment_id = aws_api_gateway_deployment.greetings_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.greetings_api.id
  stage_name    = "prod"
}

# API Gateway for contact
resource "aws_api_gateway_rest_api" "contact_api" {
  name = "${var.project_name}-${var.environment}-contact-api"
}

resource "aws_api_gateway_resource" "contact_resource" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  parent_id   = aws_api_gateway_rest_api.contact_api.root_resource_id
  path_part   = "contact"
}

resource "aws_api_gateway_method" "contact_method" {
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  resource_id   = aws_api_gateway_resource.contact_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "contact_integration" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.contact_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_contact_info.invoke_arn
}

resource "aws_lambda_permission" "allow_contact_api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_contact_info.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.contact_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "contact_deployment" {
  depends_on = [
    aws_api_gateway_integration.contact_integration,
    aws_api_gateway_integration.contact_options_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.contact_api.id

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway stage for contact
resource "aws_api_gateway_stage" "contact_stage" {
  deployment_id = aws_api_gateway_deployment.contact_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  stage_name    = "demo"
}

# OPTIONS method for contact API (CORS preflight)
resource "aws_api_gateway_method" "contact_options" {
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  resource_id   = aws_api_gateway_resource.contact_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "contact_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.contact_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "contact_options_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.contact_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "contact_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.contact_options.http_method
  status_code = aws_api_gateway_method_response.contact_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Add CORS response for POST method
resource "aws_api_gateway_method_response" "contact_post_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.contact_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}