# S3 bucket for frontend static website hosting
# CloudFront uses this bucket as origin to serve content globally
resource "aws_s3_bucket" "frontend" {
  bucket        = "${var.project_name}-frontend-${var.unique_suffix}"
  force_destroy = true
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
  name         = "${var.project_name}-greetings"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "greeting"

  attribute {
    name = "greeting"
    type = "S"
  }
}

# DynamoDB table for storing contact form submissions
resource "aws_dynamodb_table" "contacts_table" {
  name         = "${var.project_name}-contacts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "timestamp"

  attribute {
    name = "timestamp"
    type = "S"
  }
}

# Pre-populate greetings table with data
resource "aws_dynamodb_table_item" "greeting_hello" {
  table_name = aws_dynamodb_table.greetings_table.name
  hash_key   = aws_dynamodb_table.greetings_table.hash_key

  item = <<ITEM
{
  "greeting": {"S": "Hello World"}
}
ITEM
}