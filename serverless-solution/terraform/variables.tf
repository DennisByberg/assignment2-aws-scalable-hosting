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
  default     = "development"
}