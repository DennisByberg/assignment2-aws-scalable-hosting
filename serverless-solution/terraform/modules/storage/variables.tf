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
}

variable "to_email" {
  description = "Email address to send to (must be verified in SES)"
  type        = string
}