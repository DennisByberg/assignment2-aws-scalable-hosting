variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "greetings_table_name" {
  description = "Name of the greetings DynamoDB table"
  type        = string
}

variable "contacts_table_name" {
  description = "Name of the contacts DynamoDB table"
  type        = string
}

variable "lambda_greetings_role_arn" {
  description = "ARN of the Lambda greetings role"
  type        = string
}

variable "lambda_contact_role_arn" {
  description = "ARN of the Lambda contact role"
  type        = string
}