output "greetings_api_url" {
  description = "URL of the greetings API"
  value       = "${aws_api_gateway_stage.greetings_stage.invoke_url}/greetings"
}

output "contact_api_url" {
  description = "URL of the contact API"
  value       = "${aws_api_gateway_stage.contact_stage.invoke_url}/contact"
}