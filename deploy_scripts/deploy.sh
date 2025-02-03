#!/bin/bash
# deploy.sh

#usage: 
# ./deploy.sh up
# deploy down [--cleanup-docker]




set -e  # Exit on any error

# Configuration
export AWS_DEFAULT_REGION=us-west-2
export AWS_PROFILE=admin_user
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
log_info() { echo -e "${GREEN}INFO: $1${NC}"; }
log_warn() { echo -e "${YELLOW}WARN: $1${NC}"; }
log_error() { echo -e "${RED}ERROR: $1${NC}"; }

check_dependencies() {
    log_info "Checking dependencies..."
    command -v docker >/dev/null 2>&1 || { log_error "Docker is required but not installed."; exit 1; }
    command -v terraform >/dev/null 2>&1 || { log_error "Terraform is required but not installed."; exit 1; }
    command -v aws >/dev/null 2>&1 || { log_error "AWS CLI is required but not installed."; exit 1; }
}

deploy_up() {
    log_info "Starting deployment..."

    # 1. ECR Login
    log_info "Logging into ECR..."
    aws ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

    # 2. Build and Push Docker Images
    local services=("api-gateway" "weather-fetcher" "weather-processor")
    for service in "${services[@]}"; do
        log_info "Building ${service}..."
        docker build -t weather-app/${service} ./docker/${service}
        docker tag weather-app/${service}:latest ${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/weather-app/${service}:latest
        docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/weather-app/${service}:latest
    done

    # 3. Deploy Infrastructure
    log_info "Deploying infrastructure..."
    cd terraform
    terraform init
    terraform apply -auto-approve

    # 4. Wait for Services
    log_info "Waiting for services to be ready..."
    CLUSTER_NAME=$(terraform output -raw cluster_name)
    aws ecs wait services-stable \
        --cluster ${CLUSTER_NAME} \
        --services $(aws ecs list-services --cluster ${CLUSTER_NAME} --query 'serviceArns[*]' --output text)

    # 5. Get Access URL
    log_info "Getting ALB URL..."
    ALB_DNS=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[0].DNSName' --output text)
    log_info "Application is available at: http://${ALB_DNS}"

    # 6. Test Endpoint
    log_info "Testing endpoint..."
    curl -s "http://${ALB_DNS}/weather?city=London" > /dev/null
    if [ $? -eq 0 ]; then
        log_info "Deployment successful!"
    else
        log_warn "Endpoint test failed. Check logs for details."
    fi
}

deploy_down() {
    log_info "Starting cleanup..."

    # 1. Destroy Infrastructure
    cd terraform
    terraform destroy -auto-approve

    # 2. Clean Docker Images (optional)
    if [ "$1" == "--cleanup-docker" ]; then
        log_info "Cleaning up Docker images..."
        docker rmi $(docker images "weather-app/*" -q) 2>/dev/null || true
        docker rmi $(docker images "${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/weather-app/*" -q) 2>/dev/null || true
    fi

    log_info "Cleanup complete!"
}

# Main script
case $1 in
    "up")
        check_dependencies
        deploy_up
        ;;
    "down")
        check_dependencies
        deploy_down $2
        ;;
    *)
        echo "Usage: $0 up|down [--cleanup-docker]"
        echo "  up              : Deploy the application"
        echo "  down            : Destroy the infrastructure"
        echo "  --cleanup-docker: Also remove Docker images when destroying"
        exit 1
        ;;
esac