output "greetings_api_url" {
  description = "URL of the greetings API endpoint"
  value       = "${aws_api_gateway_stage.main.invoke_url}/greetings"
}

output "contact_api_url" {
  description = "URL of the contact API endpoint"
  value       = "${aws_api_gateway_stage.main.invoke_url}/contact"
}