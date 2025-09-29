terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
  }
}

# Configure how Terraform connects to AWS
provider "aws" {
  region = var.aws_region
}

# Random suffix for unique resource names
resource "random_string" "unique_suffix" {
  length  = 8
  special = false
  upper   = false
}

# SSH key generation and management for EC2 access
module "ssh" {
  source = "./modules/ssh"

  project_name = var.project_name
}

# VPC, security groups, and Application Load Balancer setup
module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
}

# S3 bucket for images and DynamoDB table for posts
module "storage" {
  source = "./modules/storage"

  project_name  = var.project_name
  unique_suffix = random_string.unique_suffix.result
}

# IAM roles and policies for EC2 instances
module "iam" {
  source = "./modules/iam"

  project_name       = var.project_name
  aws_region         = var.aws_region
  s3_bucket_arn      = module.storage.s3_bucket_arn
  dynamodb_table_arn = module.storage.dynamodb_table_arn
}

# Docker Swarm cluster with manager and Auto Scaling workers
module "compute" {
  source = "./modules/compute"

  project_name          = var.project_name
  environment           = var.environment
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  key_name              = module.ssh.key_name
  security_group_id     = module.networking.security_group_id
  instance_profile_name = module.iam.instance_profile_name
  subnet_ids            = module.networking.subnet_ids
  target_group_arns     = module.networking.target_group_arns
  desired_workers       = var.worker_count
  aws_region            = var.aws_region
}