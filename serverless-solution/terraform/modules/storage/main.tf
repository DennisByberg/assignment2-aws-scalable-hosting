# S3 bucket for frontend static website hosting
# CloudFront uses this bucket as origin to serve content globally
resource "aws_s3_bucket" "frontend" {
  bucket        = "${var.project_name}-frontend-${var.environment}-${var.unique_suffix}"
  force_destroy = true

  tags = {
    Name        = "Frontend Hosting"
    Environment = var.environment
  }
}

# Public access block - allows CloudFront access while keeping bucket secure
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# DynamoDB table for storing greeting messages
resource "aws_dynamodb_table" "greetings_table" {
  name         = "${var.project_name}-greetings-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "greeting"

  attribute {
    name = "greeting"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-greetings-${var.environment}"
    Environment = var.environment
    Purpose     = "Store greeting messages for the serverless web application"
  }
}

# DynamoDB table for storing contact form submissions
resource "aws_dynamodb_table" "contacts_table" {
  name         = "${var.project_name}-contacts-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "timestamp"

  attribute {
    name = "timestamp"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-contacts-${var.environment}"
    Environment = var.environment
    Purpose     = "Store contact form submissions from the serverless web application"
  }
}

# Pre-populate greetings table with sample data
resource "aws_dynamodb_table_item" "greeting_hello" {
  table_name = aws_dynamodb_table.greetings_table.name
  hash_key   = aws_dynamodb_table.greetings_table.hash_key

  item = <<ITEM
{
  "greeting": {"S": "Hello World"}
}
ITEM
}