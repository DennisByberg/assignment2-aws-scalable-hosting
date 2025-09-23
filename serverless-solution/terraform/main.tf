# Terraform and AWS Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.0"
    }
  }
}

# AWS Provider configuration
provider "aws" {
  region = var.aws_region
}

# S3 bucket for static website hosting
module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  environment  = var.environment
  from_email   = var.from_email
  to_email     = var.to_email
}

# Lambda function and API Gateway
module "compute" {
  source = "./modules/compute"

  project_name = var.project_name
  environment  = var.environment
  from_email   = var.from_email
  to_email     = var.to_email

  # Pass storage outputs to compute module
  greetings_table_name      = module.storage.greetings_table_name
  greetings_table_arn       = module.storage.greetings_table_arn
  contacts_table_name       = module.storage.contacts_table_name
  contacts_table_arn        = module.storage.contacts_table_arn
  contacts_table_stream_arn = module.storage.contacts_table_stream_arn
}

# CloudFront CDN
module "cdn" {
  source = "./modules/cdn"

  project_name                   = var.project_name
  environment                    = var.environment
  s3_bucket_id                   = module.storage.frontend_bucket_name
  s3_bucket_regional_domain_name = module.storage.frontend_bucket_domain
}