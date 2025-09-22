#!/bin/bash

set -e
source "$(dirname "$0")/utils.sh"

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
            --paths "/*"
    fi
}

# Test deployment endpoints
test_deployment() {
    # Test CloudFront distribution
    if [ -n "$CLOUDFRONT_URL" ]; then
        echo "Testing CloudFront endpoint..."
        for i in {1..15}; do
            if curl -s "$CLOUDFRONT_URL"; then
                echo "CloudFront test successful"
                break
            fi
            sleep 10
        done
    fi
    
    # Test S3 website endpoint
    if [ -n "$S3_WEBSITE_URL" ]; then
        echo "Testing S3 website endpoint..."
        for i in {1..5}; do
            if curl -s "http://${S3_WEBSITE_URL}"; then
                echo "S3 website test successful"
                break
            fi
            sleep 5
        done
    fi
    
    # Test greetings API
    if [ -n "$API_GATEWAY_URL" ]; then
        echo "Testing greetings API..."
        curl -s "$API_GATEWAY_URL" || echo "Greetings API test completed"
    fi
    
    # Test contact API
    if [ -n "$CONTACT_API_URL" ]; then
        echo "Testing contact API..."
        curl -s -X POST "$CONTACT_API_URL" \
             -H "Content-Type: application/json" \
             -d '{"name":"test","email":"test@example.com","message":"test"}' \
             || echo "Contact API test completed"
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

print_info "Testing deployment..."
(test_deployment) & spinner $!

print_success "Deployment completed successfully!"
print_info ""
print_info "CloudFront URL: ${CLOUDFRONT_URL}"
print_info "S3 Website URL: http://${S3_WEBSITE_URL}"
print_info "Greetings API: ${API_GATEWAY_URL}"
print_info "Contact API: ${CONTACT_API_URL}"
