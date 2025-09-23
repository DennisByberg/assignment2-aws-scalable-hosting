# S3 outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.storage.s3_bucket_name
}

output "s3_website_url" {
  description = "Website URL of the S3 bucket"
  value       = module.storage.s3_website_endpoint
}

# API Gateway outputs
output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.compute.api_gateway_url
}

output "contact_api_url" {
  description = "URL of the contact API endpoint"
  value       = module.compute.contact_api_url
}

# CloudFront outputs
output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cdn.cloudfront_domain_name
}

output "cloudfront_url" {
  description = "Complete CloudFront URL"
  value       = "https://${module.cdn.cloudfront_domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cdn.cloudfront_distribution_id
}

output "add_contact_function_arn" {
  description = "ARN of the add contact Lambda function"
  value       = module.compute.add_contact_function_arn
}

output "send_email_function_arn" {
  description = "ARN of the send email Lambda function"
  value       = module.compute.send_email_function_arn
}

output "get_greetings_function_arn" {
  description = "ARN of the get greetings Lambda function"
  value       = module.compute.get_greetings_function_arn
}

output "get_greetings_function_name" {
  description = "Name of the get greetings Lambda function"
  value       = module.compute.get_greetings_function_name
}