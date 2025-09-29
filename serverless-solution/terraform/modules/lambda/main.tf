# Data source for current AWS region
data "aws_region" "current" {}

# Create zip files for Lambda functions
data "archive_file" "get_greetings_zip" {
  type        = "zip"
  source_file = "${path.root}/../lambda/get_greetings.py"
  output_path = "${path.root}/../build/get_greetings.zip"
}

data "archive_file" "add_contact_info_zip" {
  type        = "zip"
  source_file = "${path.root}/../lambda/add_contact_info.py"
  output_path = "${path.root}/../build/add_contact_info.zip"
}

# Get greetings Lambda function
resource "aws_lambda_function" "get_greetings" {
  filename         = data.archive_file.get_greetings_zip.output_path
  function_name    = "${var.project_name}-get-greetings"
  role             = var.lambda_greetings_role_arn
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
  function_name    = "${var.project_name}-add-contact-info"
  role             = var.lambda_contact_role_arn
  handler          = "add_contact_info.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.add_contact_info_zip.output_base64sha256

  environment {
    variables = {
      CONTACTS_TABLE_NAME = var.contacts_table_name
    }
  }
}