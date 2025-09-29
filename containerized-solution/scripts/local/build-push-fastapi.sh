#!/bin/bash

set -e 
source "$(dirname "$0")/../../../shared/scripts/utils.sh"

# Configuration
AWS_REGION="eu-north-1"
IMAGE_TAG=${IMAGE_TAG:-"v1"}
APP_DIR="../../app"

# Global variables for outputs
REPO_URI=""
ACCOUNT_ID=""

# Get repository URI from Terraform state
get_repo_uri_from_terraform() {
    cd ../../terraform
    if [ ! -f terraform.tfstate ]; then
        echo "❌ Terraform state not found. Run terraform apply first."
        exit 1
    fi
    
    REPO_URI=$(terraform output -raw ecr_repository_url 2>/dev/null)
    if [ -z "$REPO_URI" ]; then
        echo "❌ ECR repository not found in Terraform state."
        exit 1
    fi
    
    ACCOUNT_ID=$(echo $REPO_URI | cut -d. -f1)
    cd - > /dev/null
}

# Login to ECR
login_to_ecr() {
    aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
}

# Build and push multi-arch image
build_and_push_image() {
    cd $APP_DIR
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t ${REPO_URI}:${IMAGE_TAG} \
        -t ${REPO_URI}:latest \
        --push \
        .
}

# Get repository configuration from Terraform
get_repo_uri_from_terraform

# Execute build process
(login_to_ecr) &
spinner $!

(build_and_push_image) &
spinner $!

echo "🎉 Build completed!"
echo "Image: ${REPO_URI}:${IMAGE_TAG}"