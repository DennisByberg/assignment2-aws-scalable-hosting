output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.frontend.bucket
}

output "greetings_table_name" {
  description = "Name of the DynamoDB greetings table"
  value       = aws_dynamodb_table.greetings_table.name
}

output "greetings_table_arn" {
  description = "ARN of the DynamoDB greetings table"
  value       = aws_dynamodb_table.greetings_table.arn
}

output "frontend_bucket_name" {
  description = "Name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.id
}

output "frontend_bucket_domain" {
  description = "Regional domain name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}

output "contacts_table_name" {
  description = "Name of the DynamoDB contacts table"
  value       = aws_dynamodb_table.contacts_table.name
}

output "contacts_table_arn" {
  description = "ARN of the DynamoDB contacts table"
  value       = aws_dynamodb_table.contacts_table.arn
}