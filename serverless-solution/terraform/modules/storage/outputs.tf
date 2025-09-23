output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.frontend.bucket
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.frontend.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}

output "s3_website_endpoint" {
  description = "Website endpoint of the S3 bucket"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

# Add missing greetings table outputs
output "greetings_table_name" {
  description = "Name of the DynamoDB greetings table"
  value       = aws_dynamodb_table.greetings_table.name
}

output "greetings_table_arn" {
  description = "ARN of the DynamoDB greetings table"
  value       = aws_dynamodb_table.greetings_table.arn
}

# Add missing frontend bucket outputs for CDN
output "frontend_bucket_name" {
  description = "Name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.id
}

output "frontend_bucket_domain" {
  description = "Regional domain name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.contact_info.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.contact_info.arn
}

output "contacts_table_name" {
  description = "Name of the DynamoDB contacts table"
  value       = aws_dynamodb_table.contacts_table.name
}

output "contacts_table_arn" {
  description = "ARN of the DynamoDB contacts table"
  value       = aws_dynamodb_table.contacts_table.arn
}

output "contacts_table_stream_arn" {
  description = "ARN of the DynamoDB contacts table stream"
  value       = aws_dynamodb_table.contacts_table.stream_arn
}