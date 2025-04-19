#!/bin/bash

# Check if all required parameters are provided
if [ "$#" -ne 8 ]; then
    echo "Usage: $0 <app_name> <namespace> <image_name> <container_port> <service_port> <app_path> <api_key> <rate_limit>"
    exit 1
fi

APP_NAME=$1
NAMESPACE=$2
IMAGE_NAME=$3
CONTAINER_PORT=$4
SERVICE_PORT=$5
APP_PATH=$6
API_KEY=$7
RATE_LIMIT=$8

# Create output directory
mkdir -p generated

# Generate app deployment and service
sed -e "s|{{APP_NAME}}|$APP_NAME|g" \
    -e "s|{{NAMESPACE}}|$NAMESPACE|g" \
    -e "s|{{IMAGE_NAME}}|$IMAGE_NAME|g" \
    -e "s|{{CONTAINER_PORT}}|$CONTAINER_PORT|g" \
    -e "s|{{SERVICE_PORT}}|$SERVICE_PORT|g" \
    app-template.yaml > generated/${APP_NAME}-app.yaml

# Generate Kong resources
sed -e "s|{{APP_NAME}}|$APP_NAME|g" \
    -e "s|{{NAMESPACE}}|$NAMESPACE|g" \
    -e "s|{{SERVICE_PORT}}|$SERVICE_PORT|g" \
    -e "s|{{APP_PATH}}|$APP_PATH|g" \
    -e "s|{{API_KEY}}|$API_KEY|g" \
    -e "s|{{RATE_LIMIT}}|$RATE_LIMIT|g" \
    kong-template.yaml > generated/${APP_NAME}-kong.yaml

# Create namespace if it doesn't exist
kubectl get namespace $NAMESPACE > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Creating namespace $NAMESPACE..."
    kubectl create namespace $NAMESPACE
fi

echo "Generated files:"
echo "- generated/${APP_NAME}-app.yaml"
echo "- generated/${APP_NAME}-kong.yaml"

echo "To apply these configurations, run:"
echo "kubectl apply -f generated/${APP_NAME}-app.yaml -f generated/${APP_NAME}-kong.yaml" 