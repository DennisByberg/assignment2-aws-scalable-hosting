output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.compute.api_gateway_url
}

output "contact_api_url" {
  description = "URL of the contact API endpoint"
  value       = module.compute.contact_api_url
}

output "cloudfront_url" {
  description = "Complete CloudFront URL"
  value       = "https://${module.cdn.cloudfront_domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cdn.cloudfront_distribution_id
}