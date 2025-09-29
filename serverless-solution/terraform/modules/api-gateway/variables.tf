variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "get_greetings_function_name" {
  description = "Name of the get greetings Lambda function"
  type        = string
}

variable "get_greetings_invoke_arn" {
  description = "Invoke ARN of the get greetings Lambda function"
  type        = string
}

variable "add_contact_info_function_name" {
  description = "Name of the add contact info Lambda function"
  type        = string
}

variable "add_contact_info_invoke_arn" {
  description = "Invoke ARN of the add contact info Lambda function"
  type        = string
}