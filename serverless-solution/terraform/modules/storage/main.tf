# S3 bucket for static website hosting
resource "aws_s3_bucket" "static_website" {
  bucket = "${var.project_name}-${var.environment}-${formatdate("YYYYMMDD-hhmm", timestamp())}"
}

# S3 bucket website configuration
resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# S3 bucket public access block configuration
resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 bucket policy for public read access
resource "aws_s3_bucket_policy" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicAccessGetObject"
        Principal = "*"
        Effect    = "Allow"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.static_website.arn}/*"]
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.static_website]
}

# S3 bucket for frontend hosting
resource "aws_s3_bucket" "frontend" {
  bucket        = "${var.project_name}-frontend-${var.environment}-${random_string.bucket_suffix.result}"
  force_destroy = true

  tags = {
    Name        = "Frontend Hosting"
    Environment = var.environment
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Public access block - will be overridden by bucket policy
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# Website configuration for fallback
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB table for storing greetings
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
    Project     = var.project_name
  }
}

# DynamoDB table for storing contacts
resource "aws_dynamodb_table" "contacts_table" {
  name         = "${var.project_name}-contacts-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "timestamp"

  attribute {
    name = "timestamp"
    type = "S"
  }

  # Enable DynamoDB Streams for email notifications
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = {
    Name        = "${var.project_name}-contacts-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Add sample greeting items
resource "aws_dynamodb_table_item" "greeting_hello" {
  table_name = aws_dynamodb_table.greetings_table.name
  hash_key   = aws_dynamodb_table.greetings_table.hash_key

  item = <<ITEM
{
  "greeting": {"S": "Hello World"}
}
ITEM
}

resource "aws_dynamodb_table_item" "greeting_swedish" {
  table_name = aws_dynamodb_table.greetings_table.name
  hash_key   = aws_dynamodb_table.greetings_table.hash_key

  item = <<ITEM
{
  "greeting": {"S": "Hej Världen"}
}
ITEM
}

# SES Email Identity for sending emails
resource "aws_ses_email_identity" "from_email" {
  email = var.from_email
}

# SES Email Identity for receiving emails
resource "aws_ses_email_identity" "to_email" {
  email = var.to_email
}

# DynamoDB table for contact form data
resource "aws_dynamodb_table" "contact_info" {
  name         = "${var.project_name}-contact-info-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "Contact Information"
    Environment = var.environment
  }
}