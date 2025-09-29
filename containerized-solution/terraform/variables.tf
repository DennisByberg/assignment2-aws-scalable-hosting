variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "docker-swarm"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "instance_type" {
  description = "EC2 instance type for all nodes"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c4fc5dcabc9df21d"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}