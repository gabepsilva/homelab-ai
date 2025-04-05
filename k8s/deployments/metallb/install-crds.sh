#!/bin/bash
# Script to install MetalLB CRDs and prepare for deployment

echo "Installing MetalLB CRDs..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml

echo "Waiting for controller and webhook to initialize (30 seconds)..."
sleep 30

echo "Checking if webhook service is running..."
kubectl -n metallb-system get service webhook-service

echo "If you encounter webhook validation errors during deployment, run:"
echo "kubectl delete -n metallb-system validatingwebhookconfiguration metallb-webhook-configuration"
echo
echo "Then apply the MetalLB configuration with:"
echo "kubectl apply -f metallb.yaml" 