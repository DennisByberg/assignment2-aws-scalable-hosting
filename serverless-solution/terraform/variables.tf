variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aws-serverless-solution"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "from_email" {
  description = "Email address to send from (must be verified in SES)"
  type        = string
  default     = "your-email@example.com"
}

variable "to_email" {
  description = "Email address to send to"
  type        = string
  default     = "your-email@example.com"
}