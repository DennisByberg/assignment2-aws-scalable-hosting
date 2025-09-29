# Lambda execution role for greetings function
resource "aws_iam_role" "lambda_greetings_role" {
  name = "${var.project_name}-lambda-greetings-role"

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
  name = "${var.project_name}-lambda-contact-role"

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

# Combined policy for greetings function
resource "aws_iam_role_policy" "lambda_greetings_policy" {
  name = "${var.project_name}-lambda-greetings-policy"
  role = aws_iam_role.lambda_greetings_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
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

# Combined policy for contact function
resource "aws_iam_role_policy" "lambda_contact_policy" {
  name = "${var.project_name}-lambda-contact-policy"
  role = aws_iam_role.lambda_contact_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        Resource = var.contacts_table_arn
      }
    ]
  })
}