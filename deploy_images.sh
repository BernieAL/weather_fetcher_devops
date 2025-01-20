#!/bin/bash

# First, let's check our AWS identity
echo "Current AWS Identity:"
aws sts get-caller-identity

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-east-1"

echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "AWS Region: $AWS_REGION"

# Authenticate with ECR
echo "Authenticating with ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

if [ $? -ne 0 ]; then
    echo "Failed to log into ECR"
    exit 1
fi

# Define service mappings (directory name -> ECR repository name)
declare -A service_mappings=(
    ["api_gateway"]="weather-app-api-gateway"
    ["weather_fetcher"]="weather-app-weather-fetcher"
    ["weather_processor"]="weather-app-weather-processor"
)

# Process each service
for service_dir in "api_gateway" "weather_fetcher" "weather_processor"
do
    echo "======================================"
    echo "Processing $service_dir..."
    
    # Get ECR repository name
    ecr_repo=${service_mappings[$service_dir]}
    
    # Check if directory exists
    if [ ! -d "./services/$service_dir" ]; then
        echo "WARNING: Directory ./services/$service_dir not found!"
        echo "Current directory contains:"
        ls -la ./services
        continue
    fi
    
    # Build the image with specific Dockerfile name
    echo "Building $service_dir..."
    docker build -t $service_dir -f ./services/$service_dir/Dockerfile.$service_dir ./services/$service_dir
    if [ $? -ne 0 ]; then
        echo "Failed to build $service_dir"
        continue
    fi
    
    # Tag the image
    echo "Tagging $service_dir..."
    docker tag $service_dir:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ecr_repo:latest
    if [ $? -ne 0 ]; then
        echo "Failed to tag $service_dir"
        continue
    fi
    
    # Push the image
    echo "Pushing $service_dir..."
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ecr_repo:latest
    if [ $? -ne 0 ]; then
        echo "Failed to push $service_dir"
        continue
    fi
    
    echo "$service_dir completed successfully"
done

echo "Script completed"