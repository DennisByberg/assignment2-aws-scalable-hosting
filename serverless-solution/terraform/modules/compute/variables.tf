variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "greetings_table_name" {
  description = "Name of the greetings DynamoDB table"
  type        = string
}

variable "greetings_table_arn" {
  description = "ARN of the greetings DynamoDB table"
  type        = string
}

variable "contacts_table_name" {
  description = "Name of the contacts DynamoDB table"
  type        = string
}

variable "contacts_table_arn" {
  description = "ARN of the contacts DynamoDB table"
  type        = string
}