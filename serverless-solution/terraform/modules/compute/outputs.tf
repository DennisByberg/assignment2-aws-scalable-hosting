output "lambda_function_name" {
  description = "Name of the greetings Lambda function"
  value       = aws_lambda_function.get_greetings.function_name
}

output "api_gateway_url" {
  description = "API Gateway invoke URL for greetings"
  value       = "${aws_api_gateway_stage.greetings_stage.invoke_url}/greetings"
}

output "contact_api_url" {
  description = "Contact form API Gateway URL"
  value       = "${aws_api_gateway_stage.contact_stage.invoke_url}/contact"
}

output "contact_lambda_name" {
  description = "Name of the contact Lambda function"
  value       = aws_lambda_function.add_contact_info.function_name
}

output "email_lambda_name" {
  description = "Name of the email Lambda function"
  value       = aws_lambda_function.send_contact_email.function_name
}

output "add_contact_function_arn" {
  description = "ARN of the add contact Lambda function"
  value       = aws_lambda_function.add_contact_info.arn
}

output "send_email_function_arn" {
  description = "ARN of the send email Lambda function"
  value       = aws_lambda_function.send_contact_email.arn
}

output "get_greetings_function_arn" {
  description = "ARN of the get greetings Lambda function"
  value       = aws_lambda_function.get_greetings.arn
}

output "get_greetings_function_name" {
  description = "Name of the get greetings Lambda function"
  value       = aws_lambda_function.get_greetings.function_name
}

output "add_contact_function_name" {
  description = "Name of the add contact Lambda function"
  value       = aws_lambda_function.add_contact_info.function_name
}