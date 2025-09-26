#!/bin/bash

set -e
source "$(dirname "$0")/../../shared/scripts/utils.sh"

AWS_REGION="eu-north-1"

S3_BUCKET_NAME=""
API_GATEWAY_URL=""
CONTACT_API_URL=""
CLOUDFRONT_URL=""
CLOUDFRONT_DISTRIBUTION_ID=""

# Deploy infrastructure
deploy_infrastructure() {
    cd ../terraform
    terraform apply -auto-approve
    cd ../scripts
}

# Get outputs from Terraform
get_terraform_outputs() {
    cd ../terraform
    S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name)
    API_GATEWAY_URL=$(terraform output -raw api_gateway_url)
    CONTACT_API_URL=$(terraform output -raw contact_api_url)
    CLOUDFRONT_URL=$(terraform output -raw cloudfront_url)
    CLOUDFRONT_DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
    cd ../scripts
}

# Upload static files to S3
upload_frontend() {
    if [ -z "$S3_BUCKET_NAME" ]; then
        echo "Error: S3 bucket name not found"
        exit 1
    fi
    
    mkdir -p /tmp/serverless-build
    
    cp -r ../app/static /tmp/serverless-build/
    
    sed "s|{{ api_gateway_url }}|${API_GATEWAY_URL}|g; s|{{ contact_api_url }}|${CONTACT_API_URL}|g" \
        ../app/templates/index.html > /tmp/serverless-build/index.html
    
    aws s3 sync /tmp/serverless-build/ s3://${S3_BUCKET_NAME}/ --delete
    
    rm -rf /tmp/serverless-build
}

# Invalidate CloudFront cache
invalidate_cloudfront() {
    if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
        aws cloudfront create-invalidation \
            --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
            --paths "/*" > /dev/null 2>&1
    fi
}

print_info "Deploying infrastructure..."
(deploy_infrastructure) & spinner $!

print_info "Getting deployment outputs..."
get_terraform_outputs

print_info "Uploading frontend to S3..."
(upload_frontend) & spinner $!

print_info "Invalidating CloudFront cache..."
(invalidate_cloudfront) & spinner $!

print_success "Deployment completed successfully!"
echo "--------------------------"
print_success "Website: ${CLOUDFRONT_URL}"
print_success "Greetings API: ${API_GATEWAY_URL}"
print_success "Contact API: ${CONTACT_API_URL}"