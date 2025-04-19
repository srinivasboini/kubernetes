#!/bin/bash

# Check if required arguments are provided
if [ "$#" -ne 8 ]; then
    echo "Usage: $0 <app_name> <namespace> <image_name> <container_port> <service_port> <app_path> <api_key> <rate_limit>"
    exit 1
fi

APP_NAME=$1
NAMESPACE=$2
# image_name, container_port, service_port are not needed for cleanup
# app_path, api_key, and rate_limit are not needed for cleanup

echo "Cleaning up resources for $APP_NAME in namespace $NAMESPACE..."

# Delete deployment
kubectl delete deployment $APP_NAME -n $NAMESPACE

# Delete service
kubectl delete service $APP_NAME -n $NAMESPACE

# Delete ingress
kubectl delete ingress $APP_NAME -n $NAMESPACE

# Delete Kong consumer
kubectl delete kongconsumer $APP_NAME-consumer -n $NAMESPACE

# Delete Kong plugins
kubectl delete kongplugin $APP_NAME-auth -n $NAMESPACE
kubectl delete kongplugin $APP_NAME-ratelimit -n $NAMESPACE

# Delete API key secret
kubectl delete secret $APP_NAME-apikey -n $NAMESPACE

echo "Cleanup completed!" 