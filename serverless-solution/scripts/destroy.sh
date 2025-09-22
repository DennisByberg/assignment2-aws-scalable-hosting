#!/bin/bash

set -e
source "$(dirname "$0")/utils.sh"

# Configuration
AWS_REGION="eu-north-1"

# Get terraform output safely - returns empty if not found
get_output() {
    local name="$1"
    cd ../terraform
    terraform output -raw "$name" 2>/dev/null || echo ""
    cd ../scripts
}

# Disable CloudFront distribution before deletion
# CloudFront must be disabled before Terraform can delete it
disable_cloudfront() {
    local distribution_id=$(get_output "cloudfront_distribution_id")
    
    if [ -z "$distribution_id" ]; then
        return 0
    fi
    
    # Check if distribution is currently enabled
    local is_enabled=$(aws cloudfront get-distribution \
        --id "$distribution_id" \
        --query 'Distribution.DistributionConfig.Enabled' \
        --output text 2>/dev/null || echo "false")
    
    if [ "$is_enabled" != "True" ]; then
        return 0
    fi
    
    # Get current configuration and ETag for update
    local etag=$(aws cloudfront get-distribution-config \
        --id "$distribution_id" \
        --query 'ETag' \
        --output text 2>/dev/null)
    
    if [ -z "$etag" ]; then
        return 0
    fi
    
    # Get current config and modify it to disable distribution
    aws cloudfront get-distribution-config \
        --id "$distribution_id" \
        --query 'DistributionConfig' > /tmp/dist-config.json
    
    # Change Enabled from true to false
    sed -i 's/"Enabled": true/"Enabled": false/g' /tmp/dist-config.json
    
    # Apply the disabled configuration
    aws cloudfront update-distribution \
        --id "$distribution_id" \
        --distribution-config file:///tmp/dist-config.json \
        --if-match "$etag" >/dev/null
    
    # Clean up temporary file
    rm -f /tmp/dist-config.json
    
    # Wait for CloudFront to finish processing the change
    # This can take several minutes
    local attempts=0
    local max_attempts=20
    
    while [ $attempts -lt $max_attempts ]; do
        local status=$(aws cloudfront get-distribution \
            --id "$distribution_id" \
            --query 'Distribution.Status' \
            --output text 2>/dev/null || echo "")
        
        if [ "$status" = "Deployed" ]; then
            break
        fi
        
        sleep 30
        attempts=$((attempts + 1))
    done
}

# Empty S3 bucket completely before Terraform destroys it
# S3 buckets must be empty before they can be deleted
empty_s3_bucket() {
    local bucket_name=$(get_output "s3_bucket_name")
    
    if [ -z "$bucket_name" ]; then
        return 0
    fi
    
    # Check if bucket exists
    if ! aws s3api head-bucket --bucket "$bucket_name" >/dev/null 2>&1; then
        return 0
    fi
    
    # Delete all object versions (for versioned buckets)
    aws s3api list-object-versions \
        --bucket "$bucket_name" \
        --query 'Versions[].[Key,VersionId]' \
        --output text 2>/dev/null | while read key version_id; do
        
        if [ -n "$key" ] && [ "$key" != "None" ]; then
            aws s3api delete-object \
                --bucket "$bucket_name" \
                --key "$key" \
                --version-id "$version_id" >/dev/null 2>&1 || true
        fi
    done
    
    # Delete all delete markers (versioned bucket cleanup)
    aws s3api list-object-versions \
        --bucket "$bucket_name" \
        --query 'DeleteMarkers[].[Key,VersionId]' \
        --output text 2>/dev/null | while read key version_id; do
        
        if [ -n "$key" ] && [ "$key" != "None" ]; then
            aws s3api delete-object \
                --bucket "$bucket_name" \
                --key "$key" \
                --version-id "$version_id" >/dev/null 2>&1 || true
        fi
    done
    
    # Remove any remaining objects (fallback cleanup)
    aws s3 rm "s3://$bucket_name" --recursive >/dev/null 2>&1 || true
    
    # Wait for AWS eventual consistency
    sleep 5
}

# Run Terraform destroy to remove all infrastructure
destroy_infrastructure() {
    cd ../terraform
    terraform destroy -auto-approve
    cd ../scripts
}

# Execute destruction process
print_info "Disabling CloudFront distribution..."
(disable_cloudfront) & spinner $!

print_info "Emptying S3 bucket..."
(empty_s3_bucket) & spinner $!

print_info "Destroying infrastructure..."
(destroy_infrastructure) & spinner $!

print_success "All AWS resources have been removed!"
print_info "CloudFront distribution disabled and infrastructure destroyed"