output "lambda_greetings_role_arn" {
  description = "ARN of the Lambda greetings role"
  value       = aws_iam_role.lambda_greetings_role.arn
}

output "lambda_contact_role_arn" {
  description = "ARN of the Lambda contact role"
  value       = aws_iam_role.lambda_contact_role.arn
}