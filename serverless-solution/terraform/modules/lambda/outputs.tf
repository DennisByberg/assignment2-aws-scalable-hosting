output "get_greetings_function_name" {
  description = "Name of the get greetings Lambda function"
  value       = aws_lambda_function.get_greetings.function_name
}

output "get_greetings_invoke_arn" {
  description = "Invoke ARN of the get greetings Lambda function"
  value       = aws_lambda_function.get_greetings.invoke_arn
}

output "add_contact_info_function_name" {
  description = "Name of the add contact info Lambda function"
  value       = aws_lambda_function.add_contact_info.function_name
}

output "add_contact_info_invoke_arn" {
  description = "Invoke ARN of the add contact info Lambda function"
  value       = aws_lambda_function.add_contact_info.invoke_arn
}