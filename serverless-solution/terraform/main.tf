terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7.1"
    }
  }
}

# Configure how Terraform connects to AWS
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Generate a random 8-character string to make resource names unique
# This prevents naming conflicts when multiple people deploy the same code
resource "random_string" "unique_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Storage module creates all storage related AWS resources
# S3 bucket for hosting the website files like HTML CSS and JS
# DynamoDB tables for storing application data like a database
module "storage" {
  source = "./modules/storage"

  project_name  = var.project_name
  environment   = var.environment
  unique_suffix = random_string.unique_suffix.result
}

# IAM module creates Lambda execution roles and security policies
# This module sets up the security permissions that allow Lambda functions to
# execute and write logs to CloudWatch, read and write data to specific DynamoDB tables
# and follow AWS principle of least privilege with only necessary permissions
module "iam" {
  source = "./modules/iam"

  project_name        = var.project_name
  environment         = var.environment
  greetings_table_arn = module.storage.greetings_table_arn
  contacts_table_arn  = module.storage.contacts_table_arn
}

# Compute module creates the serverless compute resources
# Lambda functions provide serverless code execution and API Gateway creates REST API endpoints that trigger Lambda functions
module "compute" {
  source = "./modules/compute"

  project_name              = var.project_name
  environment               = var.environment
  greetings_table_name      = module.storage.greetings_table_name
  greetings_table_arn       = module.storage.greetings_table_arn
  contacts_table_name       = module.storage.contacts_table_name
  contacts_table_arn        = module.storage.contacts_table_arn
  lambda_greetings_role_arn = module.iam.lambda_greetings_role_arn
  lambda_contact_role_arn   = module.iam.lambda_contact_role_arn
}

# CDN module creates CloudFront distribution for global content delivery
# CloudFront caches your website files worldwide for faster loading times
module "cdn" {
  source = "./modules/cdn"

  project_name                   = var.project_name
  environment                    = var.environment
  s3_bucket_id                   = module.storage.frontend_bucket_name
  s3_bucket_regional_domain_name = module.storage.frontend_bucket_domain
}