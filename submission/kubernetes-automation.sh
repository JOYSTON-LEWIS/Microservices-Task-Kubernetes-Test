#!/bin/bash

set -e

echo "🚀 Deploying User Service..."
kubectl apply -f deployment/user-deployment.yaml
kubectl apply -f services/user-service.yaml

echo "🚀 Deploying Product Service..."
kubectl apply -f deployment/product-deployment.yaml
kubectl apply -f services/product-service.yaml

echo "🚀 Deploying Order Service..."
kubectl apply -f deployment/order-deployment.yaml
kubectl apply -f services/order-service.yaml

echo "⏳ Waiting for core services to be ready..."

kubectl wait --for=condition=Ready pod -l app=user-service --timeout=60s
kubectl wait --for=condition=Ready pod -l app=product-service --timeout=60s
kubectl wait --for=condition=Ready pod -l app=order-service --timeout=60s

echo "✅ Core services are up!"

echo "🚀 Deploying Gateway Service..."
kubectl apply -f deployment/gateway-deployment.yaml
kubectl apply -f services/gateway-service.yaml

echo "✅ All services deployed successfully!"
