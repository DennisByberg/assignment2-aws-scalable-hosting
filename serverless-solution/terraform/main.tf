terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.1"
    }
    # Helps generate random values (like unique names)
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
    # Creates ZIP files for Lambda function code
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7.1"
    }
  }
}

# Configure how Terraform connects to AWS
# This sets the region and adds standard tags to ALL AWS resources
provider "aws" {
  region = var.aws_region

  # Tags help organize and track resources in AWS console
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

# This module creates all storage-related AWS resources:
# - S3 bucket for hosting the website files (HTML, CSS, JS)
# - DynamoDB tables for storing application data (like a database)
module "storage" {
  source = "./modules/storage"

  project_name  = var.project_name
  environment   = var.environment
  unique_suffix = random_string.unique_suffix.result
}

# This module creates the serverless compute resources:
# - Lambda functions (serverless code execution)
# - API Gateway (creates REST API endpoints that trigger Lambda functions)
module "compute" {
  source = "./modules/compute"

  project_name = var.project_name
  environment  = var.environment

  greetings_table_name = module.storage.greetings_table_name
  greetings_table_arn  = module.storage.greetings_table_arn
  contacts_table_name  = module.storage.contacts_table_name
  contacts_table_arn   = module.storage.contacts_table_arn
}

# This module creates CloudFront distribution for fast global content delivery
# CloudFront is AWS's CDN - it caches your website files worldwide for faster loading
module "cdn" {
  source = "./modules/cdn"

  project_name = var.project_name
  environment  = var.environment

  s3_bucket_id                   = module.storage.frontend_bucket_name
  s3_bucket_regional_domain_name = module.storage.frontend_bucket_domain
}