#!/bin/bash

set -e
source "$(dirname "$0")/../../shared/scripts/utils.sh"

AWS_REGION="eu-north-1"

# Get terraform output
get_output() {
    local name="$1"
    cd ../terraform
    terraform output -raw "$name" 2>/dev/null || echo ""
    cd ../scripts
}

# Disable CloudFront distribution before deletion
disable_cloudfront() {
    local distribution_id=$(get_output "cloudfront_distribution_id")
    
    if [ -z "$distribution_id" ]; then
        return 0
    fi
    
    local is_enabled=$(aws cloudfront get-distribution \
        --id "$distribution_id" \
        --query 'Distribution.DistributionConfig.Enabled' \
        --output text 2>/dev/null || echo "false")
    
    if [ "$is_enabled" != "True" ]; then
        return 0
    fi
    
    local etag=$(aws cloudfront get-distribution-config \
        --id "$distribution_id" \
        --query 'ETag' \
        --output text 2>/dev/null)
    
    if [ -z "$etag" ]; then
        return 0
    fi
    
    aws cloudfront get-distribution-config \
        --id "$distribution_id" \
        --query 'DistributionConfig' > /tmp/dist-config.json
    
    sed -i 's/"Enabled": true/"Enabled": false/g' /tmp/dist-config.json
    
    aws cloudfront update-distribution \
        --id "$distribution_id" \
        --distribution-config file:///tmp/dist-config.json \
        --if-match "$etag" >/dev/null
    
    rm -f /tmp/dist-config.json
    
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

# Empty S3 bucket completely
empty_s3_bucket() {
    local bucket_name=$(get_output "s3_bucket_name")
    
    if [ -z "$bucket_name" ]; then
        return 0
    fi
    
    if ! aws s3api head-bucket --bucket "$bucket_name" >/dev/null 2>&1; then
        return 0
    fi
    
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
    
    aws s3 rm "s3://$bucket_name" --recursive >/dev/null 2>&1 || true
    
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