output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = "https://${module.cdn.cloudfront_domain_name}"
}

output "api_gateway_url" {
  description = "URL of the greetings API (for backward compatibility)"
  value       = module.api_gateway.greetings_api_url
}

output "greetings_api_url" {
  description = "URL of the greetings API"
  value       = module.api_gateway.greetings_api_url
}

output "contact_api_url" {
  description = "URL of the contact API"
  value       = module.api_gateway.contact_api_url
}

output "s3_bucket_name" {
  description = "Name of the frontend S3 bucket"
  value       = module.storage.frontend_bucket_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cdn.cloudfront_distribution_id
}