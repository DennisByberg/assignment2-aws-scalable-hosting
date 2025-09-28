variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "unique_suffix" {
  description = "Random suffix for S3 bucket name"
  type        = string
}