#!/bin/bash

set -e
source "$(dirname "$0")/../../shared/scripts/utils.sh"

# Configuration
AWS_REGION="eu-north-1"
PROJECT_NAME="aws-serverless-solution"
ENVIRONMENT="demo"

# Global variables for outputs
S3_BUCKET_NAME=""
S3_WEBSITE_URL=""
API_GATEWAY_URL=""
CONTACT_API_URL=""
CLOUDFRONT_DOMAIN=""
CLOUDFRONT_URL=""
CLOUDFRONT_DISTRIBUTION_ID=""

# Deploy infrastructure using Terraform
deploy_infrastructure() {
    cd ../terraform
    terraform apply -auto-approve
    cd ../scripts
}

# Get outputs from Terraform
get_terraform_outputs() {
    cd ../terraform
    S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name)
    S3_WEBSITE_URL=$(terraform output -raw s3_website_url)
    API_GATEWAY_URL=$(terraform output -raw api_gateway_url)
    CONTACT_API_URL=$(terraform output -raw contact_api_url)
    CLOUDFRONT_DOMAIN=$(terraform output -raw cloudfront_domain_name)
    CLOUDFRONT_URL=$(terraform output -raw cloudfront_url)
    CLOUDFRONT_DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
    cd ../scripts
}

# Build React frontend with API URLs
build_frontend() {
    cd ../app/frontend
    
    # Create environment file with API endpoints
    cat > .env << EOF
VITE_API_URL=${API_GATEWAY_URL}
VITE_CONTACT_API_URL=${CONTACT_API_URL}
EOF
    
    npm install
    npm run build
    cd ../../scripts
}

# Upload frontend to S3
upload_frontend() {
    if [ -z "$S3_BUCKET_NAME" ]; then
        echo "Error: S3 bucket name not found"
        exit 1
    fi
    aws s3 sync ../app/frontend/dist/ s3://${S3_BUCKET_NAME}/ --delete
}

# Invalidate CloudFront cache for immediate updates
invalidate_cloudfront() {
    if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
        aws cloudfront create-invalidation \
            --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
            --paths "/*" > /dev/null 2>&1
    fi
}

# Execute deployment process
print_info "Deploying infrastructure..."
(deploy_infrastructure) & spinner $!

print_info "Getting deployment outputs..."
get_terraform_outputs

print_info "Building frontend..."
(build_frontend) & spinner $!

print_info "Uploading to S3..."
(upload_frontend) & spinner $!

print_info "Invalidating CloudFront cache..."
(invalidate_cloudfront) & spinner $!

print_success "Deployment completed successfully!"
echo "--------------------------"
print_success "CloudFront URL: ${CLOUDFRONT_URL}"
print_success "S3 Website URL: http://${S3_WEBSITE_URL}"
print_success "Greetings API: ${API_GATEWAY_URL}"
print_success "Contact API: ${CONTACT_API_URL}"
