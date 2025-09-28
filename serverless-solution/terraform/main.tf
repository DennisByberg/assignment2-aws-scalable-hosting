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

# AWS Provider configuration
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

# Generate unique suffix for resources
resource "random_string" "unique_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Storage layer: S3 bucket and DynamoDB tables
module "storage" {
  source = "./modules/storage"

  project_name  = var.project_name
  environment   = var.environment
  unique_suffix = random_string.unique_suffix.result
}

# Compute layer: Lambda functions and API Gateway
module "compute" {
  source = "./modules/compute"

  project_name         = var.project_name
  environment          = var.environment
  greetings_table_name = module.storage.greetings_table_name
  greetings_table_arn  = module.storage.greetings_table_arn
  contacts_table_name  = module.storage.contacts_table_name
  contacts_table_arn   = module.storage.contacts_table_arn
}

# CDN layer: CloudFront distribution
module "cdn" {
  source = "./modules/cdn"

  project_name                   = var.project_name
  environment                    = var.environment
  s3_bucket_id                   = module.storage.frontend_bucket_name
  s3_bucket_regional_domain_name = module.storage.frontend_bucket_domain
}