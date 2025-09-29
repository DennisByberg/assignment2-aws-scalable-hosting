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
}

# Random suffix for unique resource names
resource "random_string" "unique_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket and DynamoDB tables for application data
module "storage" {
  source = "./modules/storage"

  project_name  = var.project_name
  unique_suffix = random_string.unique_suffix.result
}

# IAM roles and policies for Lambda functions
module "iam" {
  source = "./modules/iam"

  project_name        = var.project_name
  greetings_table_arn = module.storage.greetings_table_arn
  contacts_table_arn  = module.storage.contacts_table_arn
}

# Lambda functions for application logic
module "lambda" {
  source = "./modules/lambda"

  project_name              = var.project_name
  greetings_table_name      = module.storage.greetings_table_name
  contacts_table_name       = module.storage.contacts_table_name
  lambda_greetings_role_arn = module.iam.lambda_greetings_role_arn
  lambda_contact_role_arn   = module.iam.lambda_contact_role_arn
}

# API Gateway REST endpoints for Lambda functions
module "api_gateway" {
  source = "./modules/api-gateway"

  project_name                   = var.project_name
  get_greetings_function_name    = module.lambda.get_greetings_function_name
  get_greetings_invoke_arn       = module.lambda.get_greetings_invoke_arn
  add_contact_info_function_name = module.lambda.add_contact_info_function_name
  add_contact_info_invoke_arn    = module.lambda.add_contact_info_invoke_arn
}

# CloudFront distribution for global content delivery
module "cdn" {
  source = "./modules/cdn"

  project_name                   = var.project_name
  s3_bucket_id                   = module.storage.frontend_bucket_name
  s3_bucket_regional_domain_name = module.storage.frontend_bucket_domain
}