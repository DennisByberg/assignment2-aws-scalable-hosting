# Data source for current AWS region
data "aws_region" "current" {}

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
  uri                     = var.get_greetings_invoke_arn
}

resource "aws_lambda_permission" "allow_greetings_api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.get_greetings_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.greetings_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "greetings_deployment" {
  depends_on  = [aws_api_gateway_integration.greetings_integration]
  rest_api_id = aws_api_gateway_rest_api.greetings_api.id
}

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
  uri                     = var.add_contact_info_invoke_arn
}

resource "aws_lambda_permission" "allow_contact_api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.add_contact_info_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.contact_api.execution_arn}/*/*"
}

# OPTIONS method for CORS
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

resource "aws_api_gateway_stage" "contact_stage" {
  deployment_id = aws_api_gateway_deployment.contact_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  stage_name    = "demo"
}