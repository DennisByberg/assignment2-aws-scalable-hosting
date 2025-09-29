variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the AWS key pair for SSH access"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group for instances"
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Auto Scaling Group"
  type        = list(string)
}

variable "target_group_arns" {
  description = "Map of target group ARNs for load balancer attachment"
  type = object({
    nginx      = string
    visualizer = string
    fastapi    = string
  })
}

variable "aws_region" {
  description = "AWS region for user data template"
  type        = string
}